#!/bin/bash

# ================= CONFIGURATION =================
# Set the base absolute path to your project root
DATA_ROOT="/nfs/lschnaitl/projects/360_v2"

# Define the full list of Nerf Synthetic scenes
# You can remove or comment out scenes you don't want to train

# indoor scenes
#SCENES=("bonsai" "counter" "kitchen" "room")

# outdoor scenes
SCENES=("bicycle" "garden" "stump")

SUB_DIR="360_v2"
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
        -i images_2 \
        --eval \

    echo "Finished processing $scene"
    echo "Starting rendering for: $scene"

    python render.py \
        -m "$MODEL_OUTPUT"
    
    echo "Finished rendering $scene"
done

echo "------------------------------------------------"
echo "All scenes processed."