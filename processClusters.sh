#!/bin/bash

set -e

echo "🧬 SeekDeep Step 4: processClusters"
echo "=================================="

INPUT_DIR="pipeline_results/all_clustered"
OUTPUT_DIR="pipeline_results/processed"

# Check if input exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "❌ ERROR: Input directory $INPUT_DIR not found!"
    echo "Run qluster.sh first"
    exit 1
fi

# Check if we have clustered results
CLUSTERED_COUNT=$(find "$INPUT_DIR" -name "output.fastq" | wc -l)
if [ "$CLUSTERED_COUNT" -eq 0 ]; then
    echo "❌ ERROR: No clustered output files found in $INPUT_DIR"
    echo "Make sure qluster.sh completed successfully"
    exit 1
fi

echo "Found $CLUSTERED_COUNT clustered files to process"
echo "Input directory: $INPUT_DIR"
echo "Output directory: $OUTPUT_DIR"
echo

mkdir -p "$OUTPUT_DIR"

echo "Running SeekDeep processClusters..."
echo "Command: SeekDeep processClusters --inputDir $INPUT_DIR --dout $OUTPUT_DIR --overWriteDir"
echo

# Run processClusters
SeekDeep processClusters \
    --inputDir "$INPUT_DIR" \
    --dout "$OUTPUT_DIR" \
    --overWriteDir \
    --verbose

PROCESS_EXIT_CODE=$?

if [ $PROCESS_EXIT_CODE -eq 0 ]; then
    echo
    echo "✅ processClusters completed successfully!"
    echo
    echo "Output directory contents:"
    ls -la "$OUTPUT_DIR"
    echo
    echo "Key output files:"
    find "$OUTPUT_DIR" -type f | head -20
    echo
    echo "🎯 Ready for Step 5: popClusteringViewer"
else
    echo
    echo "❌ processClusters failed with exit code: $PROCESS_EXIT_CODE"
    echo
    echo "Checking for error logs:"
    find "$OUTPUT_DIR" -name "*log*" -o -name "*error*" | head -5
    exit 1
fi