#!/bin/bash

DATA_ROOT="/nfs/lschnaitl/projects/nerf_synthetic"
SCENES=("chair" "drums" "ficus" "hotdog" "lego" "materials" "mic" "ship")
SUB_DIR="nerf_synthetic"

echo "Starting batch training..."

for scene in "${SCENES[@]}"; do
    SOURCE_PATH="${DATA_ROOT}/${scene}"
    MODEL_OUTPUT="output/${SUB_DIR}/${scene}"

    MODEL_PATH="output/${SUB_DIR}/${scene}/point_cloud/iteration_30000"
    OUTPUT_PATH="output/${SUB_DIR}/${scene}/mesh_meshsplat_${scene}_v3.ply"

    echo "------------------------------------------------"
    echo "Starting training for: $scene"
    echo "  Source: $SOURCE_PATH"
    echo "  Output: $MODEL_OUTPUT"

    python train.py \
        -s "$SOURCE_PATH" \
        -m "$MODEL_OUTPUT" \
        --eval \
        --white_background \
        --prune_triangles_threshold 0.3 \
        --lambda_weight 0

    echo "Rendering scene at iteration 30000..."

    python render.py \
        -m "$MODEL_OUTPUT" \
        --iteration 30000

    echo "Creating PLY mesh..."

    python create_ply.py "$MODEL_PATH" \
        --out "$OUTPUT_PATH"

    echo "Finished processing $scene"
done

echo "------------------------------------------------"
echo "All scenes processed."