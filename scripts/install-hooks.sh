#!/bin/bash

# Install Git Hooks for Playdate Pipeline
# This script installs pre-commit hooks for code quality

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Installing Git Hooks...${NC}\n"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Error: Not a git repository${NC}"
    exit 1
fi

# Get git hooks directory
HOOKS_DIR=$(git rev-parse --git-dir)/hooks

# Create pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash

# Pre-commit hook for Playdate games
# Runs validation before allowing commits

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Running pre-commit checks...${NC}\n"

# Find all game directories (directories containing Source/pdxinfo)
GAME_DIRS=$(find . -name "pdxinfo" -path "*/Source/pdxinfo" -exec dirname {} \; | xargs -I {} dirname {} | sort -u)

if [ -z "$GAME_DIRS" ]; then
    echo -e "${YELLOW}No game directories found, skipping validation${NC}"
    exit 0
fi

# Track if any validations fail
FAILED=0

# Validate each game directory
for game_dir in $GAME_DIRS; do
    # Skip if not in staging area
    if ! git diff --cached --name-only | grep -q "^$game_dir/"; then
        continue
    fi

    echo -e "${YELLOW}Validating $game_dir...${NC}"

    # Run validation script if it exists
    if [ -f "scripts/validate.sh" ]; then
        if ! ./scripts/validate.sh --source "$game_dir"; then
            FAILED=1
        fi
    fi
done

# Check Lua syntax if luac is available
if command -v luac > /dev/null 2>&1; then
    echo -e "\n${YELLOW}Checking Lua syntax...${NC}"

    STAGED_LUA=$(git diff --cached --name-only --diff-filter=ACM | grep '\.lua$' || true)

    if [ -n "$STAGED_LUA" ]; then
        for file in $STAGED_LUA; do
            if [ -f "$file" ]; then
                if ! luac -p "$file" > /dev/null 2>&1; then
                    echo -e "${RED}✗ Syntax error in $file${NC}"
                    FAILED=1
                else
                    echo -e "${GREEN}✓ $file${NC}"
                fi
            fi
        done
    fi
fi

# Check for common issues in Lua files
echo -e "\n${YELLOW}Checking for common issues...${NC}"

STAGED_LUA=$(git diff --cached --name-only --diff-filter=ACM | grep '\.lua$' || true)

if [ -n "$STAGED_LUA" ]; then
    # Check for debugger statements
    if echo "$STAGED_LUA" | xargs grep -n "debugger" > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠ Warning: debugger statement found${NC}"
    fi

    # Check for TODO/FIXME comments
    TODO_COUNT=$(echo "$STAGED_LUA" | xargs grep -n "TODO\|FIXME" 2>/dev/null | wc -l || echo 0)
    if [ "$TODO_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Found $TODO_COUNT TODO/FIXME comment(s)${NC}"
    fi
fi

# Check pdxinfo files
STAGED_PDXINFO=$(git diff --cached --name-only --diff-filter=ACM | grep 'pdxinfo$' || true)

if [ -n "$STAGED_PDXINFO" ]; then
    echo -e "\n${YELLOW}Validating pdxinfo files...${NC}"

    for file in $STAGED_PDXINFO; do
        if [ -f "$file" ]; then
            # Check required fields
            REQUIRED_FIELDS=("name" "author" "description" "bundleID" "version")

            for field in "${REQUIRED_FIELDS[@]}"; do
                if ! grep -q "^$field=" "$file"; then
                    echo -e "${RED}✗ Missing field '$field' in $file${NC}"
                    FAILED=1
                fi
            done
        fi
    done
fi

# Final result
echo ""
if [ $FAILED -eq 1 ]; then
    echo -e "${RED}Pre-commit checks failed!${NC}"
    echo -e "${YELLOW}Fix the issues above or use 'git commit --no-verify' to skip${NC}"
    exit 1
else
    echo -e "${GREEN}All pre-commit checks passed! ✓${NC}"
    exit 0
fi
EOF

# Make pre-commit hook executable
chmod +x "$HOOKS_DIR/pre-commit"

echo -e "${GREEN}✓ Pre-commit hook installed${NC}"

# Create pre-push hook
cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash

# Pre-push hook for Playdate games
# Warns about pushing to protected branches

set -e

YELLOW='\033[1;33m'
NC='\033[0m'

# Check current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Warn if pushing to main without tags
if [ "$BRANCH" = "main" ]; then
    echo -e "${YELLOW}⚠ Pushing to main branch${NC}"
    echo -e "${YELLOW}This will trigger a dev deployment to itch.io${NC}"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Push cancelled"
        exit 1
    fi
fi

exit 0
EOF

# Make pre-push hook executable
chmod +x "$HOOKS_DIR/pre-push"

echo -e "${GREEN}✓ Pre-push hook installed${NC}"

# Create commit-msg hook for conventional commits
cat > "$HOOKS_DIR/commit-msg" << 'EOF'
#!/bin/bash

# Commit message hook
# Validates commit message format (optional, can be disabled)

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Skip for merge commits
if grep -q "^Merge" "$COMMIT_MSG_FILE"; then
    exit 0
fi

# Conventional commit format (optional validation)
# Uncomment to enforce:
# PATTERN="^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}"
# if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
#     echo "Error: Commit message doesn't follow conventional format"
#     echo "Format: <type>(<scope>): <subject>"
#     echo "Example: feat(player): add double jump ability"
#     exit 1
# fi

exit 0
EOF

# Make commit-msg hook executable
chmod +x "$HOOKS_DIR/commit-msg"

echo -e "${GREEN}✓ Commit-msg hook installed${NC}"

echo -e "\n${GREEN}Git hooks installed successfully!${NC}"
echo ""
echo "Hooks installed:"
echo "  • pre-commit: Validates code before commits"
echo "  • pre-push: Warns before pushing to main"
echo "  • commit-msg: Validates commit message format"
echo ""
echo -e "${YELLOW}To skip hooks, use: git commit --no-verify${NC}"
