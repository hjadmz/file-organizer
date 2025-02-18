# File Organizer

A Bash script that automatically organizes files from common user directories (Downloads, Desktop, and Documents) into categorized folders within your Documents directory.

## Features

- Automatically monitors and organizes files from:
- Downloads folder
- Desktop
- Documents

- Organizes files into categories:
- Images
- Documents
- Audio
- Video
- Archives
- Code

## Supported File Types

### Images
- jpg, jpeg, png, gif, bmp, tiff, webp

### Documents
- pdf, doc, docx, txt, rtf, xlsx, xls, pptx, ppt

### Audio
- mp3, wav, m4a, aac, flac, ogg

### Video
- mp4, avi, mkv, mov, wmv

### Archives
- zip, rar, 7z, tar, gz

### Code
- py, java, cpp, c, h
- js, html, css, php
- sh, rb, go, rs, swift

## Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/file-organizer.git
cd file-organizer
```

2. Make the script executable:
```bash
chmod +x file-organizer
```

## Usage

Run the script:
```bash
./file-organizer
```

The script will:
1. Create necessary folders if they don't exist
2. Move files to their respective categories
3. Display progress messages during operation

## Note

- The script creates folders only if they don't already exist
- Files are moved based on their extensions
- Progress messages show which files are being moved