#!/usr/bin/env bash

# Check if bash version supports associative arrays (version 4+)
if ((BASH_VERSINFO[0] < 4)); then
    echo "This script requires bash version 4 or higher"
    echo "Current bash version: $BASH_VERSION"
    exit 1
fi

# Enable strict error handling
set -euo pipefail
IFS=$'\n\t'

# Set the base organization directory
ORGANIZE_ROOT="$HOME/Organized"

# Define source directories to monitor
SOURCE_DIRS=(
    "$HOME/Downloads"
    "$HOME/Desktop"
    "$HOME/Documents"
)

# Declare and populate the associative array
declare -A FILE_TYPES
FILE_TYPES=(
    # Development Languages - Main ones as specified
    ["dev/languages/python"]="py pyc ipynb"
    ["dev/languages/java"]="java class jar"
    ["dev/languages/javascript"]="js jsx ts tsx"
    ["dev/languages/c/c"]="c h"
    ["dev/languages/c/cpp"]="cpp hpp"
    ["dev/languages/sql"]="sql"
    ["dev/languages/swift"]="swift storyboard xib"
    ["dev/languages/php"]="php"
    ["dev/languages/applescript"]="scpt applescript scptd"
    ["dev/languages/other"]="rb go rs kt scala pl pm r cs fs vb lua"
    
    # Development - Other categories
    ["dev/database"]="db sqlite db3 bson"
    ["dev/config"]="env yaml yml plist conf ini toml properties"
    ["dev/data"]="json xml css html htm"
    
    # Documents
    ["documents/text"]="txt rtf doc docx pages md markdown"
    ["documents/spreadsheets"]="csv xlsx xls numbers ods"
    ["documents/presentations"]="ppt pptx key odp"
    ["documents/reference"]="pdf epub mobi"
    
    # Media
    ["media/images"]="jpg jpeg png heic webp tiff gif raw cr2 nef arw icns"
    ["media/audio"]="mp3 wav m4a aac flac alac aiff ogg"
    ["media/video"]="mp4 mov mkv avi wmv m4v webm"
    ["media/design"]="psd ai fig sketch xd afdesign eps svg"
    
    # System (merged with macOS)
    ["system/installers"]="dmg pkg exe msi app"
    ["system/backups"]="zip rar 7z tar gz bak backup"
    ["system/logs"]="log crash"
    ["system/automation"]="command workflow alfredworkflow terminal service"
    ["system/preferences"]="plist prefPane"
    ["system/shortcuts"]="webloc url"
    ["system/plugins"]="qlgenerator"
    
    # Others
    ["others"]="*"
)

# Function to get destination based on extension
get_destination() {
    local file="$1"
    
    # Special handling for .app folders
    if [[ -d "$file" && "$file" == *.app ]]; then
        echo "$ORGANIZE_ROOT/system/installers"
        return
    fi
    
    # Handle files without extension
    if [[ "$file" != *.* ]]; then
        echo "$ORGANIZE_ROOT/others"
        return
    fi
    
    local ext="${file##*.}"
    ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"  # Convert to lowercase
    
    # Search through defined file types
    for dir in "${!FILE_TYPES[@]}"; do
        if [[ " ${FILE_TYPES[$dir]} " =~ " $ext " ]]; then
            echo "$ORGANIZE_ROOT/$dir"
            return
        fi
    done
    
    # If no match found, return others directory
    echo "$ORGANIZE_ROOT/others"
}

# Function to safely move files
safe_move() {
    local source="$1"
    local dest_dir="$2"
    local basename_source=$(basename "$source")
    local dest="$dest_dir/$basename_source"
    
    # Skip if source doesn't exist
    [[ ! -e "$source" ]] && return 1
    
    # Create destination directory
    mkdir -p "$dest_dir"
    
    # If destination exists, add timestamp
    if [[ -e "$dest" ]]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        dest="$dest_dir/${basename_source%.*}_${timestamp}.${basename_source##*.}"
    fi
    
    # Perform the move
    if mv -n "$source" "$dest" 2>/dev/null; then
        echo "Moved: $source → $dest"
        return 0
    else
        echo "Failed to move: $source"
        return 1
    fi
}

# Function to print script header
print_header() {
    echo "======================================"
    echo "       File Organization Script       "
    echo "======================================"
    echo "Organization root: $ORGANIZE_ROOT"
    echo "Source directories:"
    for dir in "${SOURCE_DIRS[@]}"; do
        echo "  - $dir"
    done
    echo "======================================"
}

# Main script execution starts here
print_header

# Create all necessary directories
echo "Creating directory structure..."
for dir in "${!FILE_TYPES[@]}"; do
    mkdir -p "$ORGANIZE_ROOT/$dir"
done

# Main organization loop
echo "Starting file organization..."

for src_dir in "${SOURCE_DIRS[@]}"; do
    if [[ ! -d "$src_dir" ]]; then
        echo "Warning: Source directory '$src_dir' not found, skipping..."
        continue
    fi
    
    echo "Processing: $src_dir"
    
    # Find all files and .app folders, excluding hidden files
    while IFS= read -r -d $'\0' item; do
        # Skip if item is a directory but not an .app bundle
        if [[ -d "$item" && "$item" != *.app ]]; then
            continue
        fi
        
        # Get destination and move file
        dest_dir=$(get_destination "$item")
        safe_move "$item" "$dest_dir"
    done < <(find "$src_dir" -maxdepth 1 \( -type f -o \( -type d -name "*.app" \) \) -not -name ".*" -print0 2>/dev/null)
done

echo "======================================"
echo "Organization complete!"
echo "Files have been organized in: $ORGANIZE_ROOT"
echo "======================================"
