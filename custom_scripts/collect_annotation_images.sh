#!/bin/bash

SRC_ROOT="output/nerf_synthetic"
DEST_ROOT="annotation_renders/nerf_synthetic"

if [ ! -d "$SRC_ROOT" ]; then
    echo "Error: Source directory '$SRC_ROOT' does not exist."
    exit 1
fi

echo "Starting collection from $SRC_ROOT..."

for object_path in "$SRC_ROOT"/*; do
    if [ -d "$object_path" ]; then
        object_name=$(basename "$object_path")
        
        render_dir="$object_path/test/ours_30000/renders"
        
        if [ -d "$render_dir" ]; then
            image_file=$(ls "$render_dir"/*.png 2>/dev/null | head -n 1)
            
            if [ -n "$image_file" ]; then
                dest_obj_dir="$DEST_ROOT/$object_name"
                mkdir -p "$dest_obj_dir"
                
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