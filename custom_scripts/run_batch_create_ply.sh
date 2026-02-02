#!/bin/bash

# ================= CONFIGURATION =================
# Set the base absolute path to your project root

# Define the full list of Nerf Synthetic scenes
# You can remove or comment out scenes you don't want to train
SCENES=("chair" "drums" "ficus" "hotdog" "lego" "materials" "mic" "ship")
SUB_DIR="nerf_synthetic"
# =================================================

echo "Starting batch mesh creation..."

for scene in "${SCENES[@]}"; do
    MODEL_PATH="output/${SUB_DIR}/${scene}/point_cloud/iteration_30000"
    OUTPUT_PATH="output/${SUB_DIR}/${scene}/mesh_meshsplat_${scene}_v1.ply"

    echo "------------------------------------------------"
    echo "Starting mesh creation for: $scene"
    echo "  Model path: $MODEL_PATH"

    # Run the training command sequentially
    # The script will wait here until python finishes before moving to the next scene
    python create_ply.py "$MODEL_PATH" \
        --out "$OUTPUT_PATH"

    echo "Finished processing $scene"
done

echo "------------------------------------------------"
echo "All scenes processed."