#!/bin/bash

#######################################
# Create New Playdate Game from Template
# Creates a new game directory from the template
#######################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get game name
if [ -z "$1" ]; then
    echo "Usage: $0 \"Game Name\" [author]"
    echo "Example: $0 \"My Awesome Game\" \"John Doe\""
    exit 1
fi

GAME_NAME="$1"
AUTHOR="${2:-Your Name}"

# Generate directory name (lowercase, no spaces)
DIR_NAME=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Generate bundle ID
BUNDLE_ID="com.yourname.$(echo "$DIR_NAME" | tr '-' '')"

echo -e "${BLUE}Creating new Playdate game...${NC}"
echo "  Name: $GAME_NAME"
echo "  Directory: $DIR_NAME"
echo "  Author: $AUTHOR"
echo ""

# Check if directory exists
if [ -d "$DIR_NAME" ]; then
    echo -e "${YELLOW}Warning: Directory '$DIR_NAME' already exists${NC}"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
    rm -rf "$DIR_NAME"
fi

# Copy template
cp -r game-template "$DIR_NAME"

# Update pdxinfo
cat > "$DIR_NAME/Source/pdxinfo" << EOF
name=$GAME_NAME
author=$AUTHOR
description=An awesome game for Playdate!
bundleID=$BUNDLE_ID
version=1.0.0
buildNumber=1
imagePath=launcher/card
launchSoundPath=launcher/sound
EOF

echo -e "${GREEN}✓ Game created successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. cd $DIR_NAME"
echo "  2. Edit Source/main.lua"
echo "  3. Add your assets to Assets/"
echo "  4. Build: ../scripts/build.sh --source $DIR_NAME"
echo "  5. Test: ../scripts/run-simulator.sh"
echo ""
echo "Happy game making! 🎮"
