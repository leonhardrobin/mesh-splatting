#!/bin/bash

# Define source and destination root directories
SRC_ROOT="output/nerf_synthetic"
DEST_ROOT="annotation_renders/nerf_synthetic"

# Check if source directory exists
if [ ! -d "$SRC_ROOT" ]; then
    echo "Error: Source directory '$SRC_ROOT' does not exist."
    exit 1
fi

echo "Starting collection from $SRC_ROOT..."

# Iterate through each object folder in the source directory
for object_path in "$SRC_ROOT"/*; do
    if [ -d "$object_path" ]; then
        object_name=$(basename "$object_path")
        
        # Define the specific path to the renders
        # Adjusted based on your structure: object -> test -> ours_30000 -> gt -> renders
        # Note: Your structure showed 'test/ours_30000/gt' and 'test/ours_30000/renders' 
        # usually being siblings. I will look inside 'renders'.
        render_dir="$object_path/test/ours_30000/renders"
        
        # Check if the render directory exists
        if [ -d "$render_dir" ]; then
            # Find the first .png file (e.g., 00000.png)
            # We use `ls` piped to `head` to strictly get just one file
            image_file=$(ls "$render_dir"/*.png 2>/dev/null | head -n 1)
            
            if [ -n "$image_file" ]; then
                # Create the specific destination folder for this object
                dest_obj_dir="$DEST_ROOT/$object_name"
                mkdir -p "$dest_obj_dir"
                
                # Copy the image
                cp "$image_file" "$dest_obj_dir/"
                
                echo "[OK] $object_name: Copied $(basename "$image_file")"
            else
                echo "[WARNING] $object_name: No PNG images found in $render_dir"
            fi
        else
            echo "[SKIP] $object_name: Render path not found ($render_dir)"
        fi
    fi
done

echo "Done. Images collected in $DEST_ROOT"