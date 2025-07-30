#!/bin/bash

# Set your input and output directories
INPUT_DIR="CPS_DRC_pl_1"
# Automatically set output directories based on INPUT_DIR
OUTPUT_DIR="${INPUT_DIR}_results"
OUTPUT_PROCESS_DIR="${INPUT_DIR}_processed"

mkdir -p "$OUTPUT_DIR"

# Loop through each folder in the input directory
for sample_folder in "$INPUT_DIR"/*; do
    # Only process directories
    [ -d "$sample_folder" ] || continue

    sample_name=$(basename "$sample_folder")
    fastq_file="$sample_folder/output.fastq"

    # Only proceed if output.fastq exists
    if [ -f "$fastq_file" ]; then
        mkdir -p "$OUTPUT_DIR/$sample_name/rep1"
        mkdir -p "$OUTPUT_DIR/$sample_name/rep2"
        cp "$fastq_file" "$OUTPUT_DIR/$sample_name/rep1/output.fastq"
        cp "$fastq_file" "$OUTPUT_DIR/$sample_name/rep2/output.fastq"
        echo "Processed $sample_name"
    else
        echo "Warning: $fastq_file not found, skipping $sample_name"
    fi
done

echo "All done!"

sleep 2

echo "Starting processClusters for each sample in $OUTPUT_DIR"
cd "$OUTPUT_DIR"
SeekDeep processClusters --fastq output.fastq --strictErrors --dout ../$OUTPUT_PROCESS_DIR --overWriteDir --verbose --replicateMinTotalReadCutOff 100 --sampleMinTotalReadCutOff 100

sleep 2

echo "Creating config file for $OUTPUT_PROCESS_DIR"
pwd 
cd /workspaces/seekdeep
pwd

CONFIG_FILE="configs/${OUTPUT_PROCESS_DIR}.config"

cat > "$CONFIG_FILE" <<EOF
{
    "debug" : false,
    "mainDir" : "$(realpath $OUTPUT_PROCESS_DIR)/",
    "projectName" : "$OUTPUT_PROCESS_DIR",
    "shortName" : "$OUTPUT_PROCESS_DIR"
}
EOF

echo "Created config file: $CONFIG_FILE"

sleep 2 

echo "Running SeekDeep popClusteringViewer"
cd /workspaces/seekdeep
SeekDeep popClusteringViewer --configDir configs --port 9886 --verbose
