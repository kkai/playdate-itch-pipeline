#!/bin/bash

#######################################
# itch.io Deployment Script
# Deploys Playdate games to itch.io using butler
#
# Usage:
#   ./deploy-itch.sh dev              # Deploy to dev channel
#   ./deploy-itch.sh beta             # Deploy to beta channel
#   ./deploy-itch.sh stable           # Deploy to stable channel
#   ./deploy-itch.sh stable --version 1.0.0  # Deploy with version
#######################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
CHANNEL="${1:-dev}"
VERSION=""
BUILD_DIR="build"
DRY_RUN=false

# Parse additional arguments
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            echo "Usage: $0 <channel> [options]"
            echo ""
            echo "Channels:"
            echo "  dev       Development builds (default)"
            echo "  beta      Beta testing builds"
            echo "  stable    Production releases"
            echo ""
            echo "Options:"
            echo "  --version VER     Specify version number"
            echo "  --dry-run         Show what would be uploaded without uploading"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Validate channel
case $CHANNEL in
    dev|beta|stable)
        ;;
    *)
        echo -e "${RED}Error: Invalid channel '$CHANNEL'${NC}"
        echo "Valid channels: dev, beta, stable"
        exit 1
        ;;
esac

# Check for required environment variables
if [ -z "$ITCH_GAME" ]; then
    echo -e "${RED}Error: ITCH_GAME environment variable is not set${NC}"
    echo "Please set it to your itch.io game URL (format: username/game-name)"
    echo "  export ITCH_GAME=\"username/game-name\""
    exit 1
fi

# Check if butler is installed
if ! command -v butler &> /dev/null; then
    echo -e "${RED}Error: butler is not installed or not in PATH${NC}"
    echo "Install butler from: https://itch.io/docs/butler/"
    echo ""
    echo "Quick install:"
    echo "  macOS/Linux: curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default && unzip butler.zip && chmod +x butler && sudo mv butler /usr/local/bin/"
    echo "  Windows: Download from https://itch.io/docs/butler/installing.html"
    exit 1
fi

# Check if butler is logged in
if ! butler status &> /dev/null; then
    echo -e "${YELLOW}Butler is not logged in${NC}"
    echo "Please login with: butler login"
    exit 1
fi

# Find the .pdx file to upload
PDX_FILE=$(find "$BUILD_DIR" -name "*.pdx" -not -name "*-device.pdx" | head -n 1)

if [ -z "$PDX_FILE" ]; then
    echo -e "${RED}Error: No .pdx file found in $BUILD_DIR${NC}"
    echo "Please build the game first: ./scripts/build.sh"
    exit 1
fi

# Get version info
if [ -z "$VERSION" ]; then
    # Try to get version from git tag
    if git describe --tags --exact-match 2>/dev/null; then
        VERSION=$(git describe --tags --exact-match)
    else
        # Use commit hash
        VERSION=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    fi
fi

# Get game info
GAME_NAME=$(basename "$PDX_FILE" .pdx)
FILE_SIZE=$(du -sh "$PDX_FILE" | cut -f1)

# Display upload info
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}itch.io Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "  Game:     ${GREEN}$ITCH_GAME${NC}"
echo -e "  Channel:  ${YELLOW}$CHANNEL${NC}"
echo -e "  Version:  $VERSION"
echo -e "  File:     $PDX_FILE"
echo -e "  Size:     $FILE_SIZE"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN - No files will be uploaded${NC}"
    echo ""
    echo "Would execute:"
    echo "  butler push \"$PDX_FILE\" \"$ITCH_GAME:playdate-$CHANNEL\" --userversion \"$VERSION\""
    exit 0
fi

# Confirm deployment for stable channel
if [ "$CHANNEL" = "stable" ]; then
    echo -e "${YELLOW}⚠ You are about to deploy to the STABLE channel${NC}"
    echo "This will be visible to all users."
    echo ""
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled"
        exit 0
    fi
fi

# Upload to itch.io
echo -e "${YELLOW}Uploading to itch.io...${NC}"
echo ""

butler push \
    "$PDX_FILE" \
    "$ITCH_GAME:playdate-$CHANNEL" \
    --userversion "$VERSION"

# Check if upload was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Deployment successful!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Game URL: https://$ITCH_GAME"
    echo "Channel: playdate-$CHANNEL"
    echo "Version: $VERSION"
    echo ""

    # Show channel-specific info
    case $CHANNEL in
        dev)
            echo -e "${YELLOW}Development build deployed${NC}"
            echo "This build is for internal testing."
            ;;
        beta)
            echo -e "${YELLOW}Beta build deployed${NC}"
            echo "Share with beta testers for feedback."
            ;;
        stable)
            echo -e "${GREEN}Stable release deployed${NC}"
            echo "This build is now live for all users!"
            ;;
    esac

    echo ""
    echo "View on itch.io dashboard:"
    echo "  https://itch.io/dashboard/game/$( echo $ITCH_GAME | cut -d'/' -f2 )"
else
    echo ""
    echo -e "${RED}✗ Deployment failed${NC}"
    exit 1
fi
