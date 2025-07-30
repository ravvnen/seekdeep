#!/bin/bash

# ======================================================================
# SEEKDEEP SIMPLE WRAPPER - Based on your friend's working approach
# ======================================================================

echo "🧬 SeekDeep Simple Wrapper"
echo "========================="

# Configuration
FASTQ_DIR="extractor_input/raw_fastq"
ID_FILE="extractor_input/idFile_nyny.txt"
OVERLAP_FILE="extractor_input/overlap_statusny.txt"
CLEAN_DIR="seekdeep_results_clean"
OUTPUT_DIR="seekdeep_results"

# Create directories
mkdir -p "$CLEAN_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Checking require files .."
if [ ! -f "$ID_FILE" ]; then
    echo "Error: ID file $ID_FILE does not exist."
    echo "Please provide a valid ID file."
    exit 1
fi

if [ ! -f "$OVERLAP_FILE" ]; then
    echo "⚠️  Creating missing overlap status file: $OVERLAP_FILE"
    # Create a basic overlap status file
    echo -e "target\toverlap" > "$OVERLAP_FILE"
    echo -e "target1\ttrue" >> "$OVERLAP_FILE"
    echo -e "target2\ttrue" >> "$OVERLAP_FILE"
    echo "📝 Created basic overlap status file."
fi

if [ ! -d "$FASTQ_DIR" ]; then
    echo "❌ ERROR: Directory $FASTQ_DIR not found!"
    echo "Available directories in extractor_input:"
    ls -la extractor_input/ 2>/dev/null || echo "extractor_input/ doesn't exist"
    exit 1
fi

echo "✅ All required files exist"
echo

echo "Step 1: Running fastp preprocessing..."
echo "====================================="


# Run fastp on all samples
for R1 in "$FASTQ_DIR"/*_R1_001.fastq.gz; do
    R2="${R1/_R1_001.fastq.gz/_R2_001.fastq.gz}"
    SAMPLE=$(basename "$R1" _R1_001.fastq.gz)
    
    echo "Processing $SAMPLE with fastp..."
    
    fastp -i "$R1" \
        -I "$R2" \
        -o "$CLEAN_DIR/${SAMPLE}_R1_001.clean.fastq" \
        -O "$CLEAN_DIR/${SAMPLE}_R2_001.clean.fastq" \
        --detect_adapter_for_pe \
        --thread 4 \
        --cut_front \
        --cut_tail \
        --cut_window_size 4
done

echo ""
echo "Step 2: Extracting MIDs from headers and prepending to sequences..."
echo "=================================================================="

# Extract MIDs from headers and prepend to sequences
for R1 in "$CLEAN_DIR"/*_R1_001.clean.fastq; do
    R2="${R1/_R1_001.clean.fastq/_R2_001.clean.fastq}"
    SAMPLE=$(basename "$R1" _R1_001.clean.fastq)
    
    echo "Extracting MIDs for $SAMPLE..."
    
    # Process R1 file
    python3 -c "
import sys

def process_fastq(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        while True:
            header = infile.readline().strip()
            if not header:
                break
            sequence = infile.readline().strip()
            plus = infile.readline().strip()
            quality = infile.readline().strip()
            
            # Extract MID from header
            if ':' in header:
                parts = header.split(':')
                if len(parts) >= 10:
                    barcode = parts[-1]
                    if '+' in barcode:
                        barcode1, barcode2 = barcode.split('+')
                        # For R1, use first barcode
                        sequence = barcode1 + sequence
                        quality = 'I' * len(barcode1) + quality
            
            outfile.write(header + '\n')
            outfile.write(sequence + '\n')
            outfile.write(plus + '\n')
            outfile.write(quality + '\n')

process_fastq('$R1', '$R1.mid')
"
    
    # Process R2 file
    python3 -c "
import sys

def process_fastq(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        while True:
            header = infile.readline().strip()
            if not header:
                break
            sequence = infile.readline().strip()
            plus = infile.readline().strip()
            quality = infile.readline().strip()
            
            # Extract MID from header
            if ':' in header:
                parts = header.split(':')
                if len(parts) >= 10:
                    barcode = parts[-1]
                    if '+' in barcode:
                        barcode1, barcode2 = barcode.split('+')
                        # For R2, use second barcode
                        sequence = barcode2 + sequence
                        quality = 'I' * len(barcode2) + quality
            
            outfile.write(header + '\n')
            outfile.write(sequence + '\n')
            outfile.write(plus + '\n')
            outfile.write(quality + '\n')

process_fastq('$R2', '$R2.mid')
"
    
    # Replace original files with MID-processed files
    mv "$R1.mid" "$R1"
    mv "$R2.mid" "$R2"
done

echo ""
echo "Step 3: Running SeekDeep extractorPairedEnd..."
echo "==============================================="

# Run SeekDeep on all cleaned samples
for R1 in "$CLEAN_DIR"/*_R1_001.clean.fastq; do
    R2="${R1/_R1_001.clean.fastq/_R2_001.clean.fastq}"
    SAMPLE=$(basename "$R1" _R1_001.clean.fastq)
    
    echo "Processing $SAMPLE with SeekDeep extractorPairedEnd..."
    
    ./bin/SeekDeep extractorPairedEnd \
        --fastq1 "$R1" \
        --fastq2 "$R2" \
        --id "$ID_FILE" \
        --overlapStatusFnp "$OVERLAP_FILE" \
        --dout "$OUTPUT_DIR/$SAMPLE" \
        --overWriteDir
    
    echo "Done with $SAMPLE"
done

echo ""
echo "🎉 All samples processed!"
echo "========================"
echo "Cleaned files: $CLEAN_DIR/"
echo "Results: $OUTPUT_DIR/"
