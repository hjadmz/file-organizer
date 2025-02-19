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
    ["Dev/Languages/Python"]="py pyc ipynb"
    ["Dev/Languages/Java"]="java class jar"
    ["Dev/Languages/JavaScript"]="js jsx ts tsx"
    ["Dev/Languages/C/C"]="c h"
    ["Dev/Languages/C/CPP"]="cpp hpp"
    ["Dev/Languages/SQL"]="sql"
    ["Dev/Languages/Swift"]="swift storyboard xib"
    ["Dev/Languages/PHP"]="php"
    ["Dev/Languages/AppleScript"]="scpt applescript scptd"
    ["Dev/Languages/Other"]="rb go rs kt scala pl pm r cs fs vb lua"
    
    # Development - Other categories
    ["Dev/Database"]="db sqlite db3 bson"
    ["Dev/Config"]="env yaml yml plist conf ini toml properties"
    ["Dev/Data"]="json xml css html htm"
    
    # Documents
    ["Documents/Text"]="txt rtf doc docx pages md markdown"
    ["Documents/Spreadsheets"]="csv xlsx xls numbers ods"
    ["Documents/Presentations"]="ppt pptx key odp"
    ["Documents/Reference"]="pdf epub mobi"
    
    # Media
    ["Media/Images"]="jpg jpeg png heic webp tiff gif raw cr2 nef arw icns"
    ["Media/Audio"]="mp3 wav m4a aac flac alac aiff ogg"
    ["Media/Video"]="mp4 mov mkv avi wmv m4v webm"
    ["Media/Design"]="psd ai fig sketch xd afdesign eps svg"
    
    # System (merged with macOS)
    ["System/Installers"]="dmg pkg exe msi app"
    ["System/Backups"]="zip rar 7z tar gz bak backup"
    ["System/Logs"]="log crash"
    ["System/Automation"]="command workflow alfredworkflow terminal service"
    ["System/Preferences"]="plist prefPane"
    ["System/Shortcuts"]="webloc url"
    ["System/Plugins"]="qlgenerator"
    
    # Others
    ["Others"]="*"
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