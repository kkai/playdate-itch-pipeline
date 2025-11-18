# Playdate to itch.io Pipeline 🎮

**Automated pipeline for building Playdate games and publishing them to itch.io**

[![Build Status](https://github.com/yourusername/playdate-itch-pipeline/workflows/Build%20and%20Deploy/badge.svg)](https://github.com/yourusername/playdate-itch-pipeline/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This repository provides a **complete, professional-grade automated pipeline** for Playdate game development and distribution. Used by indie studios for production releases.

### What's Included

- ✅ **Game Template**: Ready-to-use Playdate game structure with asset directories
- ✅ **Example Games**: Complete Breakout implementation (more coming soon!)
- ✅ **Build Scripts**: Automated compilation for Playdate Simulator and Device
- ✅ **CI/CD Pipeline**: Multi-platform GitHub Actions workflow (Linux, macOS, Windows)
- ✅ **Multi-Channel Deployment**: Dev, Beta, and Stable release channels
- ✅ **itch.io Integration**: Automatic publishing using butler
- ✅ **Validation Tools**: Comprehensive code and asset validation
- ✅ **Git Hooks**: Pre-commit hooks for code quality
- ✅ **Makefile**: Simplified command execution
- ✅ **Comprehensive Docs**: Development, deployment, and contribution guides
- ✅ **GitHub Templates**: Issue and PR templates for professional workflow

## Features

### 🎯 Quick Start Templates
- Pre-configured game template with proper directory structure
- **Complete example games**: Breakout (crank-controlled paddle, particles, screen shake)
- Asset directories with documentation (images, sounds, fonts)
- Lua API examples and best practices

### 🔨 Build Automation
- Compile for Playdate Simulator (Mac, Windows, Linux)
- Build .pdx files for device deployment
- Automatic asset processing
- Version management

### 🚀 Continuous Deployment
- Automated builds on every commit/tag
- Direct publishing to itch.io
- Release notes generation
- Multi-platform builds

### 📦 itch.io Integration
- Automatic game uploads via butler CLI
- Version tracking
- **Three-channel deployment**: Dev (main branch), Beta (beta tags), Stable (release tags)
- Metadata synchronization
- GitHub release creation with artifacts

### 🔍 Quality Assurance
- **Comprehensive validation script**: 9 categories of automated checks
- **Pre-commit hooks**: Automatic code validation before commits
- **Pre-push warnings**: Alerts before pushing to protected branches
- **Lua syntax checking**: Catches errors before building
- **Asset validation**: Ensures all resources are properly formatted
- **pdxinfo validation**: Verifies game metadata completeness

### 🛠️ Developer Experience
- **Makefile**: Simple commands like `make build`, `make deploy-dev`
- **Quick start guide**: `make quick-start` for step-by-step setup
- **Environment checking**: `make check-env` validates your setup
- **Git hook installation**: `make install` sets up quality checks
- **Interactive releases**: `make release` guides you through versioning

## Prerequisites

### Required Software

1. **Playdate SDK**
   - Download from: https://play.date/dev/
   - Install and note the SDK path
   - Tested with SDK 2.x.x

2. **itch.io Account**
   - Create account at: https://itch.io
   - Create a game project for your Playdate game

3. **butler** (itch.io command-line tool)
   - Download from: https://itch.io/docs/butler/
   - Add to PATH

4. **Git & GitHub Account**
   - For version control and CI/CD

## Quick Start

### 1. Clone or Use Template

Click "Use this template" button on GitHub or:

```bash
git clone https://github.com/yourusername/playdate-itch-pipeline.git
cd playdate-itch-pipeline
```

### 2. Install Git Hooks

```bash
# Install pre-commit and pre-push hooks
make install

# Or manually
./scripts/install-hooks.sh
```

### 3. Configure Playdate SDK

Set the environment variable for Playdate SDK:

```bash
# macOS/Linux
export PLAYDATE_SDK_PATH="/path/to/PlaydateSDK"

# Windows (PowerShell)
$env:PLAYDATE_SDK_PATH = "C:\path\to\PlaydateSDK"

# Or add to your .bashrc / .zshrc
echo 'export PLAYDATE_SDK_PATH="/path/to/PlaydateSDK"' >> ~/.zshrc
```

### 4. Verify Environment

```bash
# Check that everything is set up correctly
make check-env
```

### 5. Build and Test

```bash
# Build for simulator
make build

# Validate your code
make validate

# Run in simulator
make run

# Or use scripts directly
./scripts/build.sh
./scripts/validate.sh
./scripts/run-simulator.sh
```

### 6. Create Your Game

```bash
# Create a new game from template
make new-game
# Follow the prompts for game name and author

# Or use the script directly
./scripts/create-game.sh "My Awesome Game" "Your Name"
```

## GitHub Actions Setup

### Configure Secrets

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

1. **PLAYDATE_SDK_PATH** (optional, using pre-installed SDK in Actions)
2. **BUTLER_API_KEY**
   - Get from: https://itch.io/user/settings/api-keys
   - Click "Generate new API key"
3. **ITCH_GAME**
   - Format: `username/game-name`
   - Example: `johndoe/awesome-playdate-game`

### Workflow Configuration

The included `.github/workflows/build-and-deploy.yml` provides **three-channel deployment**:

1. **On Push to `main`** → **Dev Channel**:
   - Build the game on all platforms
   - Run validation tests
   - Upload to itch.io `playdate-dev` channel
   - Version: Short commit hash (e.g., `a1b2c3d`)

2. **On Beta Tag** (e.g., `v1.0.0-beta.1`) → **Beta Channel**:
   - Build release version
   - Create GitHub pre-release
   - Upload to itch.io `playdate-beta` channel
   - Version: Full tag (e.g., `v1.0.0-beta.1`)

3. **On Version Tag** (e.g., `v1.0.0`) → **Stable Channel**:
   - Build production version
   - Create GitHub release with artifacts
   - Upload to itch.io `playdate-stable` channel
   - Generate release notes
   - Version: Semantic version (e.g., `v1.0.0`)

4. **On Pull Request**:
   - Build and validate only
   - Run luacheck linter
   - Validate pdxinfo
   - No deployment

## Project Structure

```
playdate-itch-pipeline/
├── .github/
│   ├── workflows/
│   │   └── build-and-deploy.yml   # Multi-platform CI/CD workflow
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md          # Bug report template
│   │   ├── feature_request.md     # Feature request template
│   │   └── game_showcase.md       # Showcase your game
│   └── PULL_REQUEST_TEMPLATE.md   # PR template
├── game-template/                  # Template for new games
│   └── Source/
│       ├── main.lua               # Main game file
│       ├── pdxinfo                # Game metadata
│       ├── images/                # Image assets (with guide)
│       ├── sounds/                # Sound assets (with guide)
│       └── fonts/                 # Font assets (with guide)
├── scripts/
│   ├── build.sh                   # Build script
│   ├── run-simulator.sh           # Run in simulator
│   ├── deploy-itch.sh             # Deploy to itch.io (3 channels)
│   ├── create-game.sh             # Create new game from template
│   ├── validate.sh                # Comprehensive validation (NEW!)
│   └── install-hooks.sh           # Install git hooks (NEW!)
├── docs/
│   ├── SETUP.md                   # Detailed setup guide
│   ├── DEVELOPMENT.md             # Complete development guide (NEW!)
│   └── DEPLOYMENT.md              # Complete deployment guide (NEW!)
├── Makefile                        # Simplified commands (NEW!)
├── CHANGELOG.md                    # Version history (NEW!)
├── CONTRIBUTING.md                 # Contribution guide (NEW!)
├── README.md                       # This file
└── LICENSE                         # MIT License
```

## Game Template Structure

```
game-template/
├── Source/
│   ├── main.lua                   # Entry point
│   ├── pdxinfo                    # Game metadata
│   ├── game.lua                   # Main game logic
│   ├── player.lua                 # Player class
│   └── utils.lua                  # Utility functions
└── Assets/
    ├── images/
    │   ├── player.png             # Player sprite
    │   └── background.png         # Background image
    ├── sounds/
    │   ├── jump.wav               # Sound effects
    │   └── music.mp3              # Background music
    └── fonts/
        └── game-font.fnt          # Custom font
```

## Creating a New Game

Use the provided script to create a new game from the template:

```bash
./scripts/create-game.sh "My Awesome Game"
```

This will:
1. Copy the game template
2. Set up the directory structure
3. Update pdxinfo with your game name
4. Initialize git (optional)

## Building Your Game

### Local Development Build

```bash
# Build for simulator (faster iteration)
./scripts/build.sh

# Build with specific name
./scripts/build.sh --name "MyGame"

# Build for device (creates .pdx)
./scripts/build.sh --device

# Clean build
./scripts/build.sh --clean
```

### Build Output

Builds are placed in the `build/` directory:
- `build/MyGame.pdx` - Simulator build
- `build/MyGame-device.pdx` - Device build

### Running in Simulator

```bash
# Automatically open in simulator
./scripts/run-simulator.sh

# Specify a different build
./scripts/run-simulator.sh build/CustomGame.pdx
```

## Deploying to itch.io

### Three-Channel Strategy

This pipeline uses a professional three-channel deployment strategy:

| Channel | Trigger | Version | Use Case |
|---------|---------|---------|----------|
| **Dev** | Push to `main` | Short hash (a1b2c3d) | Internal testing, rapid iteration |
| **Beta** | Tag `v*.*.*-beta.*` | Full tag (v1.0.0-beta.1) | Pre-release testing, QA |
| **Stable** | Tag `v*.*.*` | Semantic version (v1.0.0) | Production releases |

### Using the Makefile

```bash
# Set itch.io configuration
export ITCH_GAME="johndoe/my-playdate-game"
export BUTLER_API_KEY="your-api-key"

# Deploy to dev channel
make deploy-dev

# Deploy to beta channel
make deploy-beta

# Deploy to stable channel (with confirmation)
make deploy-stable

# Dry run (test without uploading)
make deploy-dev-dry
```

### Using Scripts Directly

```bash
# Deploy to dev channel
./scripts/deploy-itch.sh dev

# Deploy to beta channel
./scripts/deploy-itch.sh beta

# Deploy to stable channel
./scripts/deploy-itch.sh stable

# Dry run mode
./scripts/deploy-itch.sh dev --dry-run
```

### Automatic Deployment via GitHub Actions

Push to GitHub and let CI/CD handle everything:

```bash
# Development deployment (push to main)
git add .
git commit -m "Add new feature"
git push origin main
# → Automatically deploys to itch.io 'playdate-dev' channel

# Beta release deployment
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1
# → Deploys to itch.io 'playdate-beta' channel
# → Creates GitHub pre-release

# Stable release deployment
git tag v1.0.0
git push origin v1.0.0
# → Deploys to itch.io 'playdate-stable' channel
# → Creates GitHub release with artifacts
```

### Interactive Release Creation

```bash
# Create beta release (interactive)
make release-beta
# Follow prompts for version number

# Create stable release (interactive)
make release
# Follow prompts for version number
```

## Validation and Quality Checks

### Comprehensive Validation

The pipeline includes a comprehensive validation script that checks 9 categories:

```bash
# Run validation
make validate

# Or use the script directly
./scripts/validate.sh --source game-template

# Strict mode (warnings as errors)
make validate-strict
./scripts/validate.sh --source game-template --strict
```

**What gets validated:**
1. **Environment**: SDK path, pdc compiler
2. **Source Directory**: Structure and required files
3. **pdxinfo File**: Required fields, version format, bundleID
4. **Lua Code**: Syntax errors, Playdate API usage
5. **Common Issues**: Hardcoded paths, debug statements
6. **Assets**: Images, sounds, fonts directories
7. **Git**: Repository status, tags, uncommitted changes
8. **Build Directory**: Existing builds
9. **CI/CD**: GitHub Actions configuration

### Pre-commit Hooks

Installed via `make install`, these hooks automatically:

- **Pre-commit**: Validates code before each commit
  - Runs validation script
  - Checks Lua syntax
  - Validates pdxinfo files
  - Checks for common issues

- **Pre-push**: Warns before pushing to main branch
  - Confirms deployment to dev channel

- **Commit-msg**: Validates commit message format
  - Optional conventional commits

**Skip hooks when needed:**
```bash
git commit --no-verify
```

### Manual Validation

```bash
# Check environment setup
make check-env

# List available builds
make list-builds

# Show version information
make version

# Run complete dev workflow (build + validate)
make dev-workflow
```

## Development Guide

For complete development documentation, see [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)

### Lua API Basics

```lua
-- main.lua
import "CoreLibs/graphics"

local gfx = playdate.graphics

function playdate.update()
    -- Game loop (called ~30 times per second)
    gfx.clear()
    gfx.drawText("Hello Playdate!", 200, 120)
end
```

### Using the Crank

```lua
function playdate.update()
    local crankChange = playdate.getCrankChange()
    local crankPosition = playdate.getCrankPosition()

    if crankChange ~= 0 then
        print("Crank moved: " .. crankChange)
    end
end
```

### Sprites

```lua
import "CoreLibs/sprites"

local gfx = playdate.graphics

local player = gfx.sprite.new()
local playerImage = gfx.image.new("images/player")
player:setImage(playerImage)
player:moveTo(200, 120)
player:add()

function playdate.update()
    gfx.sprite.update()
end
```

### Input

```lua
function playdate.update()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        print("A button pressed!")
    end

    if playdate.buttonIsPressed(playdate.kButtonUp) then
        player:moveBy(0, -2)
    end
end
```

## Testing

### Manual Testing Checklist

- [ ] Game runs in simulator
- [ ] Game runs on device
- [ ] All assets load correctly
- [ ] Input (buttons, crank, d-pad) works
- [ ] No crashes or errors in console
- [ ] Frame rate is stable
- [ ] Audio plays correctly
- [ ] Game state persists (if applicable)

### Automated Testing (Future)

```bash
# Run unit tests (to be implemented)
./scripts/test.sh

# Run integration tests
./scripts/test.sh --integration
```

## itch.io Configuration

### Game Page Setup

1. **Create Game on itch.io**
   - Go to https://itch.io/dashboard
   - Click "Create new project"
   - Set title, URL, classification

2. **Configure Game**
   - **Kind of project**: Game
   - **Classification**: Game
   - **Platforms**: Select "Playdate"
   - **Pricing**: Free or Paid
   - **Visibility**: Public / Restricted / Draft

3. **Upload Settings**
   - Butler will handle uploads automatically
   - Channels:
     - `stable` - Release versions (tags)
     - `beta` - Beta testing
     - `dev` - Development builds (main branch)

### Butler Channels

The pipeline uses three channels:

- **stable**: Production releases (version tags)
- **beta**: Pre-release testing
- **dev**: Latest development build

## Troubleshooting

### Build Errors

**Issue**: `pdc: command not found`
```bash
# Solution: Set PLAYDATE_SDK_PATH
export PLAYDATE_SDK_PATH="/path/to/PlaydateSDK"
# Add pdc to PATH
export PATH="$PLAYDATE_SDK_PATH/bin:$PATH"
```

**Issue**: Build fails with asset errors
```bash
# Solution: Check asset paths and formats
# Images: 1-bit PNG, .pdt, .pdi
# Sounds: WAV, AIFF, MP3
# Fonts: .fnt format
```

### Deployment Errors

**Issue**: Butler authentication failed
```bash
# Solution: Verify API key
butler login
# Or set BUTLER_API_KEY environment variable
```

**Issue**: Game not appearing on itch.io
```bash
# Solution: Check game URL format
# Should be: username/game-name
# Verify game exists on itch.io dashboard
```

### Simulator Issues

**Issue**: Simulator won't launch
```bash
# macOS: Security settings may block it
# Go to System Preferences → Security & Privacy
# Click "Open Anyway" for PlaydateSimulator

# Linux: Make sure SDL is installed
sudo apt-get install libsdl2-2.0-0
```

## Advanced Usage

### Custom Build Configurations

Edit `scripts/build.sh` to add custom build steps:

```bash
# Example: Minify Lua files
pdc --strip Source build/MyGame.pdx

# Example: Include build number
BUILD_NUMBER=$(git rev-list --count HEAD)
echo "Build: $BUILD_NUMBER" >> Source/version.txt
```

### Multiple Games in One Repo

```bash
# Organize games in subdirectories
games/
├── game1/
│   └── Source/
├── game2/
│   └── Source/
└── game3/
    └── Source/

# Build specific game
./scripts/build.sh --source games/game1
```

### Environment-Specific Builds

```bash
# Development build (with debug info)
./scripts/build.sh --env development

# Production build (optimized)
./scripts/build.sh --env production
```

## Example Games

The pipeline includes complete, production-ready example games:

### 🧱 Breakout

Classic brick-breaking game with crank-controlled paddle.

**Play it to learn:**
- Crank input handling (smooth analog control)
- Physics and collision detection
- Particle systems for visual effects
- Screen shake for impact feedback
- Game state management (menu, playing, game over)
- High score persistence with datastore

**Try it:**
```bash
make build GAME_SOURCE=examples/breakout
make run
```

[View Breakout Documentation →](examples/breakout/README.md)

**More examples coming soon:**
- Snake with crank turn controls
- Pong with two-player crank paddles
- Space Invaders wave shooter
- Tetris with crank piece rotation

See [examples/README.md](examples/README.md) for details.

---

## Resources

### Official Documentation

- **Playdate SDK Docs**: https://sdk.play.date
- **Playdate Dev Forum**: https://devforum.play.date
- **Inside Playdate**: https://play.date/dev/

### itch.io Resources

- **Butler Docs**: https://itch.io/docs/butler/
- **itch.io for Developers**: https://itch.io/developers
- **API Documentation**: https://itch.io/docs/api/overview

### Community

- **Playdate Squad Discord**: https://discord.gg/playdatesquad
- **r/PlaydateConsole**: https://reddit.com/r/PlaydateConsole
- **Playdate Pulp** (web-based game maker): https://play.date/pulp/

### Example Games

- **Official Examples**: In the Playdate SDK
- **Community Games**: https://itch.io/games/tag-playdate
- **Open Source Games**: https://github.com/topics/playdate

## Contributing

We welcome contributions! This project uses professional development practices including:

- **Code Quality**: Pre-commit hooks and validation
- **Testing**: Comprehensive validation before merge
- **Documentation**: All features must be documented
- **Issue Templates**: Bug reports, feature requests, and showcases
- **PR Template**: Structured pull requests

**Quick Start for Contributors:**

1. Fork the repository
2. Install git hooks: `make install`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes
5. Validate: `make validate`
6. Commit: `git commit -m 'feat: add amazing feature'`
7. Push: `git push origin feature/amazing-feature`
8. Open a Pull Request using the template

**For detailed guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md)**

## Available Commands (Makefile)

```bash
make help              # Show all available commands
make install           # Install git hooks
make build             # Build the game
make validate          # Validate code and assets
make run               # Run in simulator
make deploy-dev        # Deploy to dev channel
make deploy-beta       # Deploy to beta channel
make deploy-stable     # Deploy to stable channel
make new-game          # Create a new game interactively
make release           # Create a stable release
make release-beta      # Create a beta release
make check-env         # Check environment setup
make clean             # Clean build directory
make quick-start       # Show quick start guide
```

For full command list, run: `make help`

## Documentation

This pipeline includes comprehensive documentation:

- **[README.md](README.md)** - This file, overview and quick start
- **[docs/SETUP.md](docs/SETUP.md)** - Detailed setup instructions
- **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** - Complete development guide
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Comprehensive deployment guide
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for full version history.

### Latest Updates

#### Enhanced Pipeline (Current)
- ✅ **Beta Channel**: Three-channel deployment (dev, beta, stable)
- ✅ **Validation Script**: 9 categories of comprehensive checks
- ✅ **Git Hooks**: Pre-commit, pre-push, and commit-msg hooks
- ✅ **Makefile**: Simplified command execution
- ✅ **GitHub Templates**: Issue and PR templates
- ✅ **Documentation**: Complete DEVELOPMENT.md and DEPLOYMENT.md guides
- ✅ **Asset Guides**: README files for images, sounds, and fonts
- ✅ **CONTRIBUTING.md**: Detailed contribution guidelines
- ✅ **Version Tracking**: CHANGELOG.md with semantic versioning

#### v1.0.0 (Initial Release)
- ✅ Game template with basic structure
- ✅ Build scripts for simulator and device
- ✅ GitHub Actions CI/CD pipeline
- ✅ itch.io deployment automation
- ✅ Multi-platform builds (Linux, macOS, Windows)
- ✅ Basic documentation

### Roadmap

#### Short Term
- [ ] Example games demonstrating features
- [ ] Unit testing framework for Lua
- [ ] Asset optimization pipeline
- [ ] Docker development environment

#### Long Term
- [ ] Steam integration
- [ ] Analytics integration
- [ ] Performance profiling tools
- [ ] Multi-language localization support
- [ ] Automated screenshot generation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Panic Inc. for the amazing Playdate console
- itch.io for butler and excellent indie game platform
- The Playdate developer community

## Support

- **Issues**: https://github.com/yourusername/playdate-itch-pipeline/issues
- **Discussions**: https://github.com/yourusername/playdate-itch-pipeline/discussions
- **Discord**: [Your Discord server]
- **Email**: [Your email]

---

**Made with ❤️ for the Playdate community**

*Happy game making! 🎮✨*
