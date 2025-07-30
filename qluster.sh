#!/bin/bash

set -e

echo "🧬 SeekDeep Step 3: qluster - Processing All Samples"
echo "==================================================="

# Create base output directory
mkdir -p pipeline_results/all_clustered

# Statistics
TOTAL_SAMPLES=0
TOTAL_FILES=0
SUCCESSFUL_FILES=0
FAILED_FILES=0

echo "Processing all samples from seekdeep_results..."
echo

# Process each sample directory
for sample_dir in seekdeep_results/*/; do
    if [ -d "$sample_dir" ]; then
        TOTAL_SAMPLES=$((TOTAL_SAMPLES + 1))
        SAMPLE_NAME=$(basename "$sample_dir")
        
        echo "[$TOTAL_SAMPLES] Processing sample: $SAMPLE_NAME"
        
        # Create sample output directory
        SAMPLE_OUTPUT_DIR="pipeline_results/all_clustered/$SAMPLE_NAME"
        mkdir -p "$SAMPLE_OUTPUT_DIR"
        
        # Process each FASTQ file in the sample directory
        SAMPLE_FILE_COUNT=0
        for fastq_file in "$sample_dir"*.fastq; do
            if [ -f "$fastq_file" ]; then
                TOTAL_FILES=$((TOTAL_FILES + 1))
                SAMPLE_FILE_COUNT=$((SAMPLE_FILE_COUNT + 1))
                
                BASENAME=$(basename "$fastq_file" .fastq)
                
                # Extract target and info from filename (e.g., K131MID69_R1 -> K131, MID69, R1)
                TARGET=$(echo "$BASENAME" | sed -E 's/(MID[0-9]+_R[12]|_R[12])$//')
                
                OUTPUT_DIR="$SAMPLE_OUTPUT_DIR/${BASENAME}_clustered"
                
                echo "  [$SAMPLE_FILE_COUNT] Target: $TARGET | File: $BASENAME"
                
                # Run qluster
                if SeekDeep qluster \
                    --fastq "$fastq_file" \
                    --illumina \
                    --dout "$OUTPUT_DIR" \
                    --overWriteDir \
                    --verbose > /dev/null 2>&1; then
                    
                    SUCCESSFUL_FILES=$((SUCCESSFUL_FILES + 1))
                    echo "      ✅ Success"
                    
                    # Check output quality
                    OUTPUT_SEQS=$(grep -c "^@" "$OUTPUT_DIR/output.fastq" 2>/dev/null || echo "0")
                    echo "      📊 Clustered sequences: $OUTPUT_SEQS"
                    
                else
                    FAILED_FILES=$((FAILED_FILES + 1))
                    echo "      ❌ Failed"
                fi
            fi
        done
        
        echo "  Sample $SAMPLE_NAME completed: $SAMPLE_FILE_COUNT files processed"
        echo
        
        # Show progress every 10 samples
        if [ $((TOTAL_SAMPLES % 10)) -eq 0 ]; then
            echo "🔄 Progress: $TOTAL_SAMPLES samples, $TOTAL_FILES files, $SUCCESSFUL_FILES successful"
            echo
        fi
    fi
done

echo "🎉 qluster Processing Complete!"
echo "================================"
echo "📊 Final Statistics:"
echo "  Total samples: $TOTAL_SAMPLES"
echo "  Total files: $TOTAL_FILES"
echo "  Successful: $SUCCESSFUL_FILES"
echo "  Failed: $FAILED_FILES"
echo "  Success rate: $(( SUCCESSFUL_FILES * 100 / TOTAL_FILES ))%"
echo
echo "📁 Output structure:"
find pipeline_results/all_clustered -maxdepth 2 -type d | head -10
echo
echo "📄 Sample output files:"
find pipeline_results/all_clustered -name "output.fastq" | head -5
echo
echo "💾 Total output size:"
du -sh pipeline_results/all_clustered/
echo
echo "🎯 Ready for Step 4: processClusters"