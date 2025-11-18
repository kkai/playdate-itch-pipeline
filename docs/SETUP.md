# Setup Guide

Complete setup instructions for the Playdate to itch.io Pipeline.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [itch.io Configuration](#itchio-configuration)
4. [GitHub Actions Setup](#github-actions-setup)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

#### 1. Playdate SDK

**Download:** https://play.date/dev/

**Installation:**

- **macOS**: Download and mount the .dmg, drag to Applications
- **Windows**: Download and run the installer
- **Linux**: Extract the tar.gz to your preferred location

**Verify Installation:**
```bash
# macOS
ls ~/Developer/PlaydateSDK

# Linux
ls ~/PlaydateSDK

# Windows (PowerShell)
dir "C:\Users\YourName\Documents\PlaydateSDK"
```

#### 2. butler (itch.io CLI)

**Download:** https://itch.io/docs/butler/installing.html

**Quick Install:**

```bash
# macOS/Linux
curl -L -o butler.zip https://broth.itch.ovh/butler/darwin-amd64/LATEST/archive/default
unzip butler.zip
chmod +x butler
sudo mv butler /usr/local/bin/

# Verify
butler -V
```

```powershell
# Windows (PowerShell as Administrator)
Invoke-WebRequest -Uri "https://broth.itch.ovh/butler/windows-amd64/LATEST/archive/default" -OutFile butler.zip
Expand-Archive -Path butler.zip -DestinationPath "C:\Program Files\butler"
# Add to PATH manually or:
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\butler", "Machine")

# Verify
butler -V
```

#### 3. Git & GitHub Account

- Install Git: https://git-scm.com/downloads
- Create GitHub account: https://github.com

## Local Development Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/playdate-itch-pipeline.git
cd playdate-itch-pipeline
```

### Step 2: Set Environment Variables

Add these to your shell configuration file:

**macOS/Linux** (`~/.zshrc` or `~/.bashrc`):
```bash
# Playdate SDK
export PLAYDATE_SDK_PATH="$HOME/Developer/PlaydateSDK"

# Add pdc to PATH
export PATH="$PLAYDATE_SDK_PATH/bin:$PATH"

# itch.io (optional for local deployment)
export ITCH_GAME="yourusername/your-game-name"
```

**Windows** (PowerShell Profile):
```powershell
# Open profile
notepad $PROFILE

# Add these lines:
$env:PLAYDATE_SDK_PATH = "C:\Users\YourName\Documents\PlaydateSDK"
$env:PATH += ";$env:PLAYDATE_SDK_PATH\bin"
$env:ITCH_GAME = "yourusername/your-game-name"
```

**Apply changes:**
```bash
# macOS/Linux
source ~/.zshrc  # or ~/.bashrc

# Windows
. $PROFILE
```

### Step 3: Verify Setup

```bash
# Check SDK
echo $PLAYDATE_SDK_PATH
pdc --version

# Check butler
butler -V

# Check scripts are executable (macOS/Linux)
chmod +x scripts/*.sh
```

### Step 4: Create Your First Game

```bash
# Use the template creation script
./scripts/create-game.sh "My First Game" "Your Name"

# Or manually copy the template
cp -r game-template my-first-game
cd my-first-game
```

### Step 5: Build and Test

```bash
# Build for simulator
./scripts/build.sh --source my-first-game

# Run in simulator
./scripts/run-simulator.sh

# Build for device
./scripts/build.sh --source my-first-game --device
```

## itch.io Configuration

### Step 1: Create itch.io Account

1. Go to https://itch.io
2. Click "Register"
3. Complete the registration process

### Step 2: Create Game Project

1. Go to https://itch.io/dashboard
2. Click "Create new project"
3. Fill in the details:
   - **Title**: Your game name
   - **Project URL**: `yourusername/game-name` (note this!)
   - **Classification**: Game
   - **Kind of project**: Game
   - **Platforms**: Check "Playdate"

4. **Important**: Leave as "Draft" until you're ready to publish

### Step 3: Get API Key

1. Go to https://itch.io/user/settings/api-keys
2. Click "Generate new API key"
3. Name it: "Playdate Pipeline"
4. Copy the key (you'll need it for GitHub Actions)

### Step 4: Configure butler

```bash
# Login to butler
butler login

# This will open a browser for authentication
# Alternatively, use API key:
butler login --api-key YOUR_API_KEY_HERE

# Verify login
butler status
```

### Step 5: Test Manual Upload

```bash
# Set your game URL
export ITCH_GAME="yourusername/game-name"

# Test upload to dev channel
./scripts/deploy-itch.sh dev
```

## GitHub Actions Setup

### Step 1: Push to GitHub

```bash
# Create repository on GitHub (via web interface)
# Then push:
git remote add origin https://github.com/yourusername/playdate-itch-pipeline.git
git push -u origin main
```

### Step 2: Add Repository Secrets

Go to your GitHub repository:
1. Click "Settings"
2. Click "Secrets and variables" → "Actions"
3. Click "New repository secret"

Add these secrets:

**BUTLER_API_KEY**
- Value: Your itch.io API key from earlier
- Used for: Automated uploads to itch.io

**ITCH_GAME**
- Value: `yourusername/game-name` (your itch.io game URL)
- Used for: Specifying which game to upload to

### Step 3: Enable Actions

1. Go to "Actions" tab in your repository
2. Click "I understand my workflows, go ahead and enable them"

### Step 4: Test the Workflow

**Option A: Push to main** (deploys to dev channel)
```bash
git add .
git commit -m "Test CI/CD pipeline"
git push origin main
```

**Option B: Create a release** (deploys to stable channel)
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Step 5: Monitor Build

1. Go to "Actions" tab
2. Click on the latest workflow run
3. Watch the build progress
4. Check for any errors

## Troubleshooting

### SDK Issues

**Problem**: `pdc: command not found`

**Solution:**
```bash
# Verify SDK path
echo $PLAYDATE_SDK_PATH

# If empty, set it:
export PLAYDATE_SDK_PATH="/path/to/PlaydateSDK"

# Add to PATH
export PATH="$PLAYDATE_SDK_PATH/bin:$PATH"

# Test
pdc --version
```

**Problem**: Build fails with "Unable to locate SDK"

**Solution:**
- Check SDK is fully installed (look for `bin/pdc`)
- Ensure no spaces in path
- On Windows, use forward slashes: `C:/path/to/SDK`

### butler Issues

**Problem**: `butler: command not found`

**Solution:**
```bash
# Check if installed
which butler  # macOS/Linux
where butler  # Windows

# If not found, reinstall and ensure it's in PATH
```

**Problem**: Authentication failed

**Solution:**
```bash
# Re-login
butler logout
butler login

# Or use API key directly
butler login --api-key YOUR_KEY
```

### GitHub Actions Issues

**Problem**: Workflow fails with "Secret not found"

**Solution:**
- Verify secrets are added correctly (check spelling)
- Secrets are case-sensitive
- Re-add the secrets if needed

**Problem**: SDK download fails

**Solution:**
- Check the SDK version in `.github/workflows/build-and-deploy.yml`
- Update to latest version number
- Verify download URL is correct

### Build Issues

**Problem**: Assets not found

**Solution:**
- Check file paths are relative to `Source/` directory
- Verify asset files exist
- Check file extensions (case-sensitive on Linux)

**Problem**: Lua syntax errors

**Solution:**
```bash
# Install luacheck for linting
# macOS
brew install luarocks
luarocks install luacheck

# Linux
sudo apt-get install luarocks
sudo luarocks install luacheck

# Run linter
luacheck Source/*.lua
```

## Next Steps

After setup is complete:

1. **Customize the template** - Edit `game-template/Source/main.lua`
2. **Add assets** - Place images, sounds in `game-template/Assets/`
3. **Test frequently** - Build and run after each change
4. **Commit often** - Use git to track your progress
5. **Deploy when ready** - Tag releases to publish to itch.io

## Additional Resources

- **Playdate SDK Docs**: https://sdk.play.date
- **itch.io Butler Docs**: https://itch.io/docs/butler/
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Playdate Dev Forum**: https://devforum.play.date

## Getting Help

- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions
- **Community**: Join Playdate Squad Discord

---

**Setup complete! Start building your Playdate game! 🎮**
