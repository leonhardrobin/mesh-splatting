#!/bin/bash

# ================= CONFIGURATION =================
# Set the base absolute path to your project root
DATA_ROOT="/nfs/lschnaitl/projects/nerf_synthetic"

# Define the full list of Nerf Synthetic scenes
# You can remove or comment out scenes you don't want to train
SCENES=("drums" "ficus" "hotdog" "materials" "mic" "ship")
SUB_DIR="nerf_synthetic"
# =================================================

echo "Starting batch training..."

for scene in "${SCENES[@]}"; do
    SOURCE_PATH="${DATA_ROOT}/${scene}"
    MODEL_OUTPUT="output/${SUB_DIR}/${scene}"

    echo "------------------------------------------------"
    echo "Starting training for: $scene"
    echo "  Source: $SOURCE_PATH"
    echo "  Output: $MODEL_OUTPUT"

    # Run the training command sequentially
    # The script will wait here until python finishes before moving to the next scene
    python train.py \
        -s "$SOURCE_PATH" \
        -m "$MODEL_OUTPUT" \
        --eval
    
    echo "Finished processing $scene"
done

echo "------------------------------------------------"
echo "All scenes processed."