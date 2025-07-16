#!/bin/bash

# ======================================================================
# SEEKDEEP EASY WRAPPER
# Zero-configuration SeekDeep processing - just run it!
# ======================================================================

echo "🧬 SeekDeep Easy Wrapper"
echo "======================="
echo "This script will automatically process ALL FASTQ files in your raw_fastq directory"
echo ""

# ======================================================================
# CONFIGURATION - Edit these paths if your files are named differently
# ======================================================================
ID_FILE="extractor_input/idFile_nyny.txt"
OVERLAP_FILE="extractor_input/overlap_statusny.txt"
FASTQ_DIR="extractor_input/raw_fastq"
OUTPUT_BASE="seekdeep_results"

echo "📋 Configuration:"
echo "   ID file: $ID_FILE"
echo "   Overlap file: $OVERLAP_FILE"
echo "   FASTQ directory: $FASTQ_DIR"
echo "   Output base: $OUTPUT_BASE"
echo ""

# Check if files exist
if [[ ! -f "$ID_FILE" ]]; then
    echo "❌ Error: ID file not found: $ID_FILE"
    echo "Edit the ID_FILE path at the top of this script"
    exit 1
fi

if [[ ! -f "$OVERLAP_FILE" ]]; then
    echo "❌ Error: Overlap file not found: $OVERLAP_FILE"
    echo "Edit the OVERLAP_FILE path at the top of this script"
    exit 1
fi

if [[ ! -d "$FASTQ_DIR" ]]; then
    echo "❌ Error: FASTQ directory not found: $FASTQ_DIR"
    echo "Edit the FASTQ_DIR path at the top of this script"
    exit 1
fi

# Check if SeekDeep binary exists
if [[ ! -f "./bin/SeekDeep" ]]; then
    echo "❌ Error: SeekDeep binary not found at ./bin/SeekDeep"
    echo "Make sure you're running this from the SeekDeep directory and it's compiled"
    exit 1
fi

# Create preprocessor function
preprocess_id_file() {
    local input_file="$1"
    local output_file="$2"
    
    echo "🔧 Preprocessing ID file..."
    
    # Check and fix Windows line endings
    if hexdump -C "$input_file" | grep -q " 0d "; then
        echo "   ⚠️  Windows line endings detected - converting to Unix format..."
        if command -v dos2unix >/dev/null 2>&1; then
            # Create temp copy and convert
            cp "$input_file" "${input_file}.temp"
            dos2unix "${input_file}.temp" 2>/dev/null
            input_file="${input_file}.temp"
        else
            echo "   📝 dos2unix not found - using sed to remove carriage returns..."
            cp "$input_file" "${input_file}.temp"
            sed -i 's/\r$//' "${input_file}.temp"
            input_file="${input_file}.temp"
        fi
        echo "   ✅ Line endings fixed"
    fi
    
    # Check for BOM and remove if present
    if hexdump -C "$input_file" | head -1 | grep -q "ef bb bf"; then
        echo "   ⚠️  BOM (Byte Order Mark) detected - removing..."
        sed -i '1s/^\xEF\xBB\xBF//' "$input_file"
        echo "   ✅ BOM removed"
    fi
    
    # Read the file and process it
    {
        # Find where the MID section starts (look for "ID" line)
        mid_start_line=$(grep -n "^ID" "$input_file" | head -1 | cut -d: -f1)
        
        if [ -z "$mid_start_line" ]; then
            echo "   ❌ Error: Could not find MID section starting with 'ID'"
            exit 1
        fi
        
        # Copy everything up to the MID section header
        head -$((mid_start_line-1)) "$input_file"
        
        # Add the ID header line
        echo -e "ID\tBARCODE\tBARCODE2"
        
        # Process MID section: convert IDs to MID format and barcodes to uppercase
        tail -n +$((mid_start_line+1)) "$input_file" | awk 'BEGIN {OFS="\t"} NF >= 2 {
            # Convert ID to MID format
            $1 = sprintf("MID%03d", NR)
            
            # Convert barcode(s) to uppercase
            $2 = toupper($2)
            if (NF >= 3) $3 = toupper($3)
            
            print
        }'
    } > "$output_file"
    
    # Cleanup temp file if created
    if [[ -f "${1}.temp" ]]; then
        rm -f "${1}.temp"
    fi
    
    local mid_count=$(tail -n +12 "$output_file" | grep -c "^MID")
    echo "   ✅ Converted $mid_count MIDs to proper format"
    echo "   ✅ Converted all barcodes to uppercase"
}

# Function to fix any text file for Windows line endings
fix_file_format() {
    local file="$1"
    local file_type="$2"
    
    echo "🔧 Checking $file_type file format..."
    
    # Check and fix Windows line endings
    if hexdump -C "$file" | grep -q " 0d "; then
        echo "   ⚠️  Windows line endings detected in $file_type file - fixing..."
        if command -v dos2unix >/dev/null 2>&1; then
            dos2unix "$file" 2>/dev/null
        else
            sed -i 's/\r$//' "$file"
        fi
        echo "   ✅ Line endings fixed"
    fi
    
    # Check for BOM and remove if present
    if hexdump -C "$file" | head -1 | grep -q "ef bb bf"; then
        echo "   ⚠️  BOM detected in $file_type file - removing..."
        sed -i '1s/^\xEF\xBB\xBF//' "$file"
        echo "   ✅ BOM removed"
    fi
    
    echo "   ✅ $file_type file format checked"
}

# Start processing
echo "🚀 Starting SeekDeep Easy Processing..."
echo ""

# Fix file formats first
fix_file_format "$OVERLAP_FILE" "overlap status"

# Preprocess ID file
TEMP_ID_FILE="temp_preprocessed_id_file.txt"
preprocess_id_file "$ID_FILE" "$TEMP_ID_FILE"

# Count total MIDs from preprocessed file
TOTAL_MIDS=$(grep -c "^MID" "$TEMP_ID_FILE")

echo "📊 Processing Plan:"
echo "   Total MIDs in reference: $TOTAL_MIDS"
echo "   Each sample will be matched against all MIDs to find its corresponding barcode"
echo ""

# Find all R1 files and match them with R2
echo "🔍 Scanning for FASTQ file pairs..."
R1_FILES=($(find "$FASTQ_DIR" -name "*_R1_001.fastq.gz" | sort))
TOTAL_PAIRS=${#R1_FILES[@]}

if [[ $TOTAL_PAIRS -eq 0 ]]; then
    echo "❌ No R1 FASTQ files found in $FASTQ_DIR"
    echo "   Looking for files matching: *_R1_001.fastq.gz"
    exit 1
fi

echo "   Found $TOTAL_PAIRS R1 files"
echo ""

# Process each pair
SUCCESSFUL_PAIRS=0
FAILED_PAIRS=0

for R1_FILE in "${R1_FILES[@]}"; do
    # Generate R2 filename
    R2_FILE="${R1_FILE/_R1_001.fastq.gz/_R2_001.fastq.gz}"
    
    # Check if R2 exists
    if [[ ! -f "$R2_FILE" ]]; then
        echo "❌ Warning: R2 file not found for $(basename "$R1_FILE")"
        echo "   Expected: $(basename "$R2_FILE")"
        FAILED_PAIRS=$((FAILED_PAIRS + 1))
        continue
    fi
    
    # Create output directory based on filename
    BASENAME=$(basename "$R1_FILE" _R1_001.fastq.gz)
    OUTPUT_DIR="${OUTPUT_BASE}/${BASENAME}"
    
    echo "=== Processing Pair $((SUCCESSFUL_PAIRS + FAILED_PAIRS + 1))/$TOTAL_PAIRS ==="
    echo "   R1: $(basename "$R1_FILE")"
    echo "   R2: $(basename "$R2_FILE")"
    echo "   Output: $OUTPUT_DIR"
    echo ""
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Run SeekDeep with full MID file - let it figure out which MID this sample corresponds to
    echo "🚀 Running SeekDeep for this sample..."
    echo "   SeekDeep will automatically identify which MID this sample corresponds to"
    echo ""
    
    # Run SeekDeep with the full preprocessed ID file
    if timeout 300s ./bin/SeekDeep extractorPairedEnd \
        --id "$TEMP_ID_FILE" \
        --overlapStatusFnp "$OVERLAP_FILE" \
        --fastq1gz "$R1_FILE" \
        --fastq2gz "$R2_FILE" \
        --dout "$OUTPUT_DIR" \
        --overWriteDir 2>/dev/null; then
        
        echo "✅ SUCCESS! SeekDeep processing completed for this sample!"
        echo "   Results are in: $OUTPUT_DIR"
        SUCCESSFUL_PAIRS=$((SUCCESSFUL_PAIRS + 1))
    else
        echo "❌ FAILED! SeekDeep processing failed for this sample"
        FAILED_PAIRS=$((FAILED_PAIRS + 1))
    fi
    
    echo ""
    echo "----------------------------------------"
    echo ""
done

# Cleanup temp files
rm -f "$TEMP_ID_FILE"

# Final summary
echo "📊 FINAL SUMMARY:"
echo "================="
echo "Total pairs found: $TOTAL_PAIRS"
echo "Successful: $SUCCESSFUL_PAIRS"
echo "Failed: $FAILED_PAIRS"

if [[ $SUCCESSFUL_PAIRS -gt 0 ]]; then
    echo ""
    echo "🎉 SUCCESS! Auto-processing completed!"
    echo "📁 Results are in: $OUTPUT_BASE/"
    echo "   Each sample has its own directory"
    echo "   SeekDeep automatically identified which MID each sample corresponds to"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Check individual sample directories in $OUTPUT_BASE/"
    echo "   2. Each directory contains results for one sample's identified MID"
    echo "   3. Analyze results for each sample"
else
    echo ""
    echo "❌ No samples processed successfully"
    echo "🔍 Troubleshooting:"
    echo "   1. Check that your FASTQ files contain valid barcodes matching the MID file"
    echo "   2. Verify FASTQ files are not corrupted"
    echo "   3. Ensure sufficient disk space and memory"
    echo "   4. Check SeekDeep logs for detailed error messages"
fi

echo ""
echo "✨ SeekDeep Easy Wrapper completed!"