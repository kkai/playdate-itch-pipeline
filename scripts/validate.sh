#!/bin/bash

# Playdate Game Validation Script
# Performs comprehensive checks on game project before build/deploy

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
CHECKS=0

# Function to print colored output
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
    ((CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
    ((CHECKS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Parse command line arguments
SOURCE_DIR="game-template"
STRICT_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --source)
            SOURCE_DIR="$2"
            shift 2
            ;;
        --strict)
            STRICT_MODE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --source DIR    Source directory to validate (default: game-template)"
            echo "  --strict        Treat warnings as errors"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_header "Playdate Game Validation"

# 1. Check Playdate SDK
print_header "1. Environment Checks"

if [ -z "$PLAYDATE_SDK_PATH" ]; then
    print_error "PLAYDATE_SDK_PATH environment variable not set"
    print_info "Set it with: export PLAYDATE_SDK_PATH=/path/to/PlaydateSDK"
else
    print_success "PLAYDATE_SDK_PATH is set: $PLAYDATE_SDK_PATH"

    if [ ! -d "$PLAYDATE_SDK_PATH" ]; then
        print_error "SDK directory does not exist: $PLAYDATE_SDK_PATH"
    else
        print_success "SDK directory exists"
    fi

    # Check for pdc compiler
    if [ -f "$PLAYDATE_SDK_PATH/bin/pdc" ] || [ -f "$PLAYDATE_SDK_PATH/bin/pdc.exe" ]; then
        print_success "pdc compiler found"
    else
        print_error "pdc compiler not found in SDK"
    fi
fi

# 2. Check source directory
print_header "2. Source Directory Checks"

if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory not found: $SOURCE_DIR"
    echo -e "\n${RED}Critical error: Cannot continue without source directory${NC}"
    exit 1
fi

print_success "Source directory exists: $SOURCE_DIR"

SOURCE_CODE_DIR="$SOURCE_DIR/Source"
if [ ! -d "$SOURCE_CODE_DIR" ]; then
    print_error "Source/  subdirectory not found in $SOURCE_DIR"
else
    print_success "Source/ subdirectory found"
fi

# 3. Check pdxinfo file
print_header "3. pdxinfo Validation"

PDXINFO_PATH="$SOURCE_CODE_DIR/pdxinfo"
if [ ! -f "$PDXINFO_PATH" ]; then
    print_error "pdxinfo file not found at $PDXINFO_PATH"
else
    print_success "pdxinfo file exists"

    # Validate required fields
    REQUIRED_FIELDS=("name" "author" "description" "bundleID" "version")

    for field in "${REQUIRED_FIELDS[@]}"; do
        if grep -q "^$field=" "$PDXINFO_PATH"; then
            value=$(grep "^$field=" "$PDXINFO_PATH" | cut -d'=' -f2)
            if [ -z "$value" ]; then
                print_warning "Field '$field' is empty"
            else
                print_success "Field '$field' is set"
            fi
        else
            print_error "Required field '$field' missing from pdxinfo"
        fi
    done

    # Check version format
    if grep -q "^version=" "$PDXINFO_PATH"; then
        version=$(grep "^version=" "$PDXINFO_PATH" | cut -d'=' -f2)
        if [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            print_success "Version format is valid (semantic versioning): $version"
        else
            print_warning "Version format doesn't follow semantic versioning: $version"
        fi
    fi

    # Check bundleID format
    if grep -q "^bundleID=" "$PDXINFO_PATH"; then
        bundleID=$(grep "^bundleID=" "$PDXINFO_PATH" | cut -d'=' -f2)
        if [[ $bundleID =~ ^[a-z]+\.[a-z0-9-]+(\.[a-z0-9-]+)*$ ]]; then
            print_success "bundleID format is valid: $bundleID"
        else
            print_warning "bundleID format should be reverse domain notation: $bundleID"
        fi
    fi
fi

# 4. Check Lua files
print_header "4. Lua Code Validation"

LUA_FILES=$(find "$SOURCE_CODE_DIR" -name "*.lua" 2>/dev/null | wc -l)
if [ "$LUA_FILES" -eq 0 ]; then
    print_error "No Lua files found in $SOURCE_CODE_DIR"
else
    print_success "Found $LUA_FILES Lua file(s)"
fi

# Check for main.lua
if [ -f "$SOURCE_CODE_DIR/main.lua" ]; then
    print_success "main.lua exists"

    # Check for basic Playdate API usage
    if grep -q "import.*CoreLibs" "$SOURCE_CODE_DIR/main.lua"; then
        print_success "CoreLibs import found"
    else
        print_warning "No CoreLibs imports found in main.lua"
    fi

    if grep -q "playdate\.update" "$SOURCE_CODE_DIR/main.lua"; then
        print_success "playdate.update() function found"
    else
        print_warning "playdate.update() function not found in main.lua"
    fi
else
    print_error "main.lua not found"
fi

# Check for syntax errors using luac if available
if command -v luac &> /dev/null; then
    print_info "Running Lua syntax check..."
    SYNTAX_ERRORS=0
    while IFS= read -r lua_file; do
        if ! luac -p "$lua_file" > /dev/null 2>&1; then
            print_error "Syntax error in: $lua_file"
            ((SYNTAX_ERRORS++))
        fi
    done < <(find "$SOURCE_CODE_DIR" -name "*.lua")

    if [ "$SYNTAX_ERRORS" -eq 0 ]; then
        print_success "No Lua syntax errors found"
    fi
else
    print_info "luac not available, skipping syntax check"
fi

# 5. Check for common issues
print_header "5. Common Issues Check"

# Check for hardcoded paths
if grep -r "\/Users\|\/home\|C:\\\\" "$SOURCE_CODE_DIR" --include="*.lua" > /dev/null 2>&1; then
    print_warning "Hardcoded file paths detected in Lua files"
else
    print_success "No hardcoded paths found"
fi

# Check for print statements (should use playdate.debugDraw or logger)
PRINT_COUNT=$(grep -r "print(" "$SOURCE_CODE_DIR" --include="*.lua" 2>/dev/null | wc -l)
if [ "$PRINT_COUNT" -gt 0 ]; then
    print_warning "Found $PRINT_COUNT print() statement(s) - consider using playdate API logging"
else
    print_success "No print() statements found"
fi

# 6. Asset checks
print_header "6. Asset Checks"

# Check for common asset directories
ASSET_DIRS=("images" "fonts" "sounds" "music")
FOUND_ASSETS=false

for dir in "${ASSET_DIRS[@]}"; do
    if [ -d "$SOURCE_CODE_DIR/$dir" ]; then
        file_count=$(find "$SOURCE_CODE_DIR/$dir" -type f | wc -l)
        if [ "$file_count" -gt 0 ]; then
            print_success "Found $file_count file(s) in $dir/"
            FOUND_ASSETS=true
        else
            print_info "$dir/ directory exists but is empty"
        fi
    fi
done

if [ "$FOUND_ASSETS" = false ]; then
    print_info "No asset directories found (this is OK for code-only games)"
fi

# Check for large files
print_info "Checking for large files (>1MB)..."
LARGE_FILES=$(find "$SOURCE_DIR" -type f -size +1M 2>/dev/null)
if [ -n "$LARGE_FILES" ]; then
    print_warning "Large files found:"
    echo "$LARGE_FILES" | while read -r file; do
        size=$(du -h "$file" | cut -f1)
        echo "  - $file ($size)"
    done
else
    print_success "No large files found"
fi

# 7. Git checks
print_header "7. Version Control Checks"

if git rev-parse --git-dir > /dev/null 2>&1; then
    print_success "Git repository detected"

    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        print_warning "Uncommitted changes detected"
    else
        print_success "Working directory is clean"
    fi

    # Check current branch
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    print_info "Current branch: $BRANCH"

    # Check for tags
    TAG_COUNT=$(git tag | wc -l)
    if [ "$TAG_COUNT" -eq 0 ]; then
        print_info "No git tags found (create tags for versioned releases)"
    else
        LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
        print_info "Latest tag: $LATEST_TAG"
    fi
else
    print_warning "Not a git repository"
fi

# 8. Build directory check
print_header "8. Build Directory Check"

if [ -d "build" ]; then
    BUILD_COUNT=$(find build -name "*.pdx" 2>/dev/null | wc -l)
    if [ "$BUILD_COUNT" -gt 0 ]; then
        print_info "Found $BUILD_COUNT existing build(s)"
        find build -name "*.pdx" -exec ls -lh {} \; | while read -r line; do
            echo "  $line"
        done
    else
        print_info "build/ directory exists but no .pdx files found"
    fi
else
    print_info "No build/ directory (will be created on first build)"
fi

# 9. CI/CD checks
print_header "9. CI/CD Configuration"

if [ -f ".github/workflows/build-and-deploy.yml" ]; then
    print_success "GitHub Actions workflow found"

    # Check for required secrets (can't validate values, just document)
    print_info "Required GitHub Secrets:"
    echo "  - BUTLER_API_KEY"
    echo "  - ITCH_GAME"
else
    print_warning "GitHub Actions workflow not found"
fi

if [ -f ".gitignore" ]; then
    print_success ".gitignore file exists"

    # Check if .pdx files are ignored
    if grep -q "\.pdx" ".gitignore"; then
        print_success ".pdx files are gitignored"
    else
        print_warning ".pdx files should be added to .gitignore"
    fi
else
    print_warning ".gitignore file not found"
fi

# Summary
print_header "Validation Summary"

echo -e "Total checks:  ${CHECKS}"
echo -e "${GREEN}Passed:        ${CHECKS - ERRORS - WARNINGS}${NC}"
echo -e "${YELLOW}Warnings:      ${WARNINGS}${NC}"
echo -e "${RED}Errors:        ${ERRORS}${NC}"

# Exit code
if [ "$ERRORS" -gt 0 ]; then
    echo -e "\n${RED}Validation FAILED with $ERRORS error(s)${NC}"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    if [ "$STRICT_MODE" = true ]; then
        echo -e "\n${RED}Validation FAILED in strict mode with $WARNINGS warning(s)${NC}"
        exit 1
    else
        echo -e "\n${YELLOW}Validation PASSED with $WARNINGS warning(s)${NC}"
        exit 0
    fi
else
    echo -e "\n${GREEN}Validation PASSED! Everything looks good. 🎮${NC}"
    exit 0
fi
