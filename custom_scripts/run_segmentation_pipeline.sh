#!/bin/bash

# Define paths
SOURCE_DATASET_ROOT="/nfs/lschnaitl/projects/nerf_synthetic"
OUTPUT_ROOT="output/nerf_synthetic"
ANNOTATION_ROOT="annotation_renders/nerf_synthetic"

# Check if output directory exists
if [ ! -d "$OUTPUT_ROOT" ]; then
    echo "Error: Output directory '$OUTPUT_ROOT' not found."
    exit 1
fi

echo "Starting segmentation pipeline..."

# Iterate over each scene folder in the output directory
for scene_path in "$OUTPUT_ROOT"/*; do
    if [ -d "$scene_path" ]; then
        scene=$(basename "$scene_path")
        
        echo "========================================"
        echo "Processing Scene: $scene"
        echo "========================================"

        # Define specific paths for this scene
        SOURCE_PATH="$SOURCE_DATASET_ROOT/$scene"
        MODEL_PATH="$OUTPUT_ROOT/$scene"
        ANNOTATION_JSON="$ANNOTATION_ROOT/$scene/00000.sam_prompts.json"
        
        # Check if the annotation JSON file exists before starting
        if [ ! -f "$ANNOTATION_JSON" ]; then
            echo "[SKIP] Annotation file not found: $ANNOTATION_JSON"
            continue
        fi

        # 1. Extract Images
        echo "Step 1: Extracting images..."
        python -m segmentation.extract_images -s "$SOURCE_PATH" -m "$MODEL_PATH" --eval
        if [ $? -ne 0 ]; then echo "Error in extract_images for $scene"; continue; fi

        # 2. SAM Mask Generator
        # Note: 'train_views' is created by extract_images inside the model path
        echo "Step 2: Generating SAM masks..."
        python -m segmentation.sam_mask_generator_json \
            --data_path "$MODEL_PATH/train_views" \
            --save_path "$MODEL_PATH/masks" \
            --json_path "$ANNOTATION_JSON"
        if [ $? -ne 0 ]; then echo "Error in sam_mask_generator_json for $scene"; continue; fi

        # 3. Segment (Propagate masks)
        echo "Step 3: Propagating segmentation..."
        python -m segmentation.segment \
            -m "$MODEL_PATH" \
            --eval \
            --path_mask "$MODEL_PATH/masks/" \
            --object_id 1
        if [ $? -ne 0 ]; then echo "Error in segmentation.segment for $scene"; continue; fi

        # 4. Run Single Object Extraction
        echo "Step 4: Running single object extraction..."
        python -m segmentation.run_single_object \
            -m "$MODEL_PATH" \
            --eval \
            --ratio_threshold 0.90
        if [ $? -ne 0 ]; then echo "Error in run_single_object for $scene"; continue; fi

        # 5. Create PLY
        echo "Step 5: Creating PLY file..."
        python -m segmentation.create_ply "$MODEL_PATH" \
            --out "$MODEL_PATH/segmented_object.ply"
        if [ $? -ne 0 ]; then echo "Error in create_ply for $scene"; continue; fi

        echo "SUCCESS: Finished processing $scene"
        echo ""
    fi
done

echo "All scenes processed."