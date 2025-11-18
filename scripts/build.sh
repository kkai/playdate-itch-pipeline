#!/bin/bash

#######################################
# Playdate Game Build Script
# Builds Playdate games for simulator and device
#
# Usage:
#   ./build.sh                    # Build for simulator
#   ./build.sh --device           # Build for device
#   ./build.sh --clean            # Clean build directory
#   ./build.sh --name "MyGame"    # Specify game name
#   ./build.sh --source game1     # Build specific game directory
#######################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
BUILD_FOR_DEVICE=false
CLEAN_BUILD=false
GAME_NAME=""
SOURCE_DIR="game-template"
BUILD_DIR="build"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --device)
            BUILD_FOR_DEVICE=true
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        --name)
            GAME_NAME="$2"
            shift 2
            ;;
        --source)
            SOURCE_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --device          Build for Playdate device"
            echo "  --clean           Clean build directory before building"
            echo "  --name NAME       Specify game name (default: from pdxinfo)"
            echo "  --source DIR      Source directory (default: game-template)"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check for Playdate SDK
if [ -z "$PLAYDATE_SDK_PATH" ]; then
    echo -e "${RED}Error: PLAYDATE_SDK_PATH environment variable is not set${NC}"
    echo "Please set it to your Playdate SDK location:"
    echo "  export PLAYDATE_SDK_PATH=\"/path/to/PlaydateSDK\""
    exit 1
fi

# Check if pdc compiler exists
PDC="$PLAYDATE_SDK_PATH/bin/pdc"
if [ ! -f "$PDC" ]; then
    echo -e "${RED}Error: pdc compiler not found at $PDC${NC}"
    echo "Please check your PLAYDATE_SDK_PATH"
    exit 1
fi

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory '$SOURCE_DIR' not found${NC}"
    exit 1
fi

# Get game name from pdxinfo if not specified
if [ -z "$GAME_NAME" ]; then
    if [ -f "$SOURCE_DIR/Source/pdxinfo" ]; then
        GAME_NAME=$(grep "^name=" "$SOURCE_DIR/Source/pdxinfo" | cut -d'=' -f2)
    else
        echo -e "${YELLOW}Warning: pdxinfo not found, using directory name${NC}"
        GAME_NAME=$(basename "$SOURCE_DIR")
    fi
fi

# Clean build directory if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir -p "$BUILD_DIR"

# Set output name
if [ "$BUILD_FOR_DEVICE" = true ]; then
    OUTPUT_NAME="${GAME_NAME}-device.pdx"
else
    OUTPUT_NAME="${GAME_NAME}.pdx"
fi

OUTPUT_PATH="$BUILD_DIR/$OUTPUT_NAME"

# Build the game
echo -e "${GREEN}Building Playdate game...${NC}"
echo "  Game: $GAME_NAME"
echo "  Source: $SOURCE_DIR/Source"
echo "  Output: $OUTPUT_PATH"
echo "  Target: $([ "$BUILD_FOR_DEVICE" = true ] && echo "Device" || echo "Simulator")"
echo ""

# Run pdc compiler
echo -e "${YELLOW}Running pdc compiler...${NC}"

if [ "$BUILD_FOR_DEVICE" = true ]; then
    # Build for device (strips debug info)
    "$PDC" --strip "$SOURCE_DIR/Source" "$OUTPUT_PATH"
else
    # Build for simulator (includes debug info)
    "$PDC" "$SOURCE_DIR/Source" "$OUTPUT_PATH"
fi

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Build successful!${NC}"
    echo "  Output: $OUTPUT_PATH"

    # Get build size
    BUILD_SIZE=$(du -sh "$OUTPUT_PATH" | cut -f1)
    echo "  Size: $BUILD_SIZE"

    # Count source files
    LUA_FILES=$(find "$SOURCE_DIR/Source" -name "*.lua" | wc -l | tr -d ' ')
    echo "  Lua files: $LUA_FILES"

    # Show next steps
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    if [ "$BUILD_FOR_DEVICE" = true ]; then
        echo "  1. Connect your Playdate device via USB"
        echo "  2. Copy $OUTPUT_PATH to your device"
        echo "  3. Or use: pdutil install $OUTPUT_PATH"
    else
        echo "  1. Run in simulator: ./scripts/run-simulator.sh"
        echo "  2. Or open: $OUTPUT_PATH"
    fi
else
    echo ""
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
