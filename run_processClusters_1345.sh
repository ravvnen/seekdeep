#!/bin/bash

set -e

echo "🧬 SeekDeep Step 4: processClusters"
echo "=================================="

# Working with the successful qluster result
QLUSTER_DIR="1345_S1411__CPMPMID67.fastq_qluster"
STRUCTURED_INPUT="structured_input_1345"
OUTPUT_DIR="processed_1345"

# Check if we have the qluster result
if [ ! -f "$QLUSTER_DIR/output.fastq" ]; then
    echo "❌ ERROR: qluster output not found at $QLUSTER_DIR/output.fastq"
    exit 1
fi

# Check if output.fastq has data
if [ ! -s "$QLUSTER_DIR/output.fastq" ]; then
    echo "❌ ERROR: output.fastq is empty"
    exit 1
fi

echo "✅ Found qluster output: $QLUSTER_DIR/output.fastq"
echo "   Sequences: $(($(wc -l < "$QLUSTER_DIR/output.fastq") / 4))"
echo

# Create the 3-level directory structure that processClusters expects
echo "Creating structured input directory..."
rm -rf "$STRUCTURED_INPUT"
mkdir -p "$STRUCTURED_INPUT/1345_S1411/CPMPMID67/rep1"

# Copy the output.fastq to the structured location
cp "$QLUSTER_DIR/output.fastq" "$STRUCTURED_INPUT/1345_S1411/CPMPMID67/rep1/"

echo "✅ Structured input created:"
echo "   $STRUCTURED_INPUT/1345_S1411/CPMPMID67/rep1/output.fastq"
echo "   Sequences: $(($(wc -l < "$STRUCTURED_INPUT/1345_S1411/CPMPMID67/rep1/output.fastq") / 4))"
echo

# Clean output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Running SeekDeep processClusters..."
echo "Command: SeekDeep processClusters --inputDir $STRUCTURED_INPUT --dout $OUTPUT_DIR --verbose"
echo

# Run processClusters
SeekDeep processClusters \
    --inputDir "$STRUCTURED_INPUT" \
    --dout "$OUTPUT_DIR" \
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
    echo "📁 final/ - Final haplotypes per sample"
    ls -la "$OUTPUT_DIR/final/" 2>/dev/null || echo "   (no final directory)"
    echo "📁 population/ - Population analysis"
    ls -la "$OUTPUT_DIR/population/" 2>/dev/null || echo "   (no population directory)"
    echo "📊 selectedClustersInfo.tab.txt.gz - Main results table"
    ls -la "$OUTPUT_DIR/selectedClustersInfo.tab.txt.gz" 2>/dev/null || echo "   (no selectedClustersInfo file)"
    echo
    echo "🎯 Ready for Step 5: Setup PopClusteringViewer config"
else
    echo
    echo "❌ processClusters failed with exit code: $PROCESS_EXIT_CODE"
    exit 1
fi
