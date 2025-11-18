#!/bin/bash

#######################################
# Run Playdate Game in Simulator
# Opens the game in Playdate Simulator
#######################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check for Playdate SDK
if [ -z "$PLAYDATE_SDK_PATH" ]; then
    echo -e "${RED}Error: PLAYDATE_SDK_PATH not set${NC}"
    exit 1
fi

# Find simulator executable
if [ "$(uname)" == "Darwin" ]; then
    SIMULATOR="$PLAYDATE_SDK_PATH/bin/Playdate Simulator.app/Contents/MacOS/Playdate Simulator"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    SIMULATOR="$PLAYDATE_SDK_PATH/bin/PlaydateSimulator"
else
    SIMULATOR="$PLAYDATE_SDK_PATH/PlaydateSimulator.exe"
fi

# Find .pdx file
if [ -n "$1" ]; then
    PDX_FILE="$1"
else
    PDX_FILE=$(find build -name "*.pdx" -not -name "*-device.pdx" | head -n 1)
fi

if [ -z "$PDX_FILE" ]; then
    echo -e "${RED}Error: No .pdx file found${NC}"
    echo "Build the game first: ./scripts/build.sh"
    exit 1
fi

echo -e "${GREEN}Running in Playdate Simulator...${NC}"
echo "  File: $PDX_FILE"

# Launch simulator
"$SIMULATOR" "$PDX_FILE"
