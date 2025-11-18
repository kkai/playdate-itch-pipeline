# Playdate to itch.io Pipeline 🎮

**Automated pipeline for building Playdate games and publishing them to itch.io**

[![Build Status](https://github.com/yourusername/playdate-itch-pipeline/workflows/Build%20and%20Deploy/badge.svg)](https://github.com/yourusername/playdate-itch-pipeline/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This repository provides a complete automated pipeline for Playdate game development and distribution. It includes:

- ✅ **Game Template**: Ready-to-use Playdate game structure
- ✅ **Build Scripts**: Automated compilation for Playdate Simulator and Device
- ✅ **CI/CD Pipeline**: GitHub Actions workflow for automated building
- ✅ **itch.io Integration**: Automatic publishing to itch.io using butler
- ✅ **Example Games**: Sample games demonstrating the pipeline
- ✅ **Documentation**: Complete setup and usage guide

## Features

### 🎯 Quick Start Templates
- Pre-configured game template with proper directory structure
- Example games with sprites, sounds, and crank input
- Lua and C API support

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
- Multiple channel support (stable, beta, dev)
- Metadata synchronization

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

### 1. Use This Template

Click "Use this template" button on GitHub or:

```bash
git clone https://github.com/yourusername/playdate-itch-pipeline.git
cd playdate-itch-pipeline
```

### 2. Set Up Your Game

```bash
# Copy the template to start your game
cp -r game-template my-awesome-game
cd my-awesome-game

# Edit the game metadata
nano Source/pdxinfo
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

### 4. Build Locally

```bash
# Build for simulator
./scripts/build.sh

# Build for device
./scripts/build.sh --device

# Run in simulator
./scripts/run-simulator.sh
```

### 5. Test Your Game

```bash
# Open in Playdate Simulator
open build/MyGame.pdx  # macOS
# or
"$PLAYDATE_SDK_PATH/bin/PlaydateSimulator" build/MyGame.pdx  # Linux/Windows
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

The included `.github/workflows/build-and-deploy.yml` will:

1. **On Push to `main`**:
   - Build the game
   - Run tests (if configured)
   - Upload to itch.io `dev` channel

2. **On Version Tag** (e.g., `v1.0.0`):
   - Build release version
   - Create GitHub release
   - Upload to itch.io `stable` channel
   - Generate release notes

3. **On Pull Request**:
   - Build and test only
   - No deployment

## Project Structure

```
playdate-itch-pipeline/
├── .github/
│   └── workflows/
│       └── build-and-deploy.yml   # GitHub Actions workflow
├── game-template/                  # Template for new games
│   ├── Source/
│   │   ├── main.lua               # Main game file
│   │   └── pdxinfo                # Game metadata
│   └── Assets/
│       ├── images/                # Sprites and graphics
│       ├── sounds/                # Audio files
│       └── fonts/                 # Custom fonts
├── examples/
│   └── simple-game/               # Example Playdate game
├── scripts/
│   ├── build.sh                   # Build script
│   ├── run-simulator.sh           # Run in simulator
│   ├── deploy-itch.sh             # Deploy to itch.io
│   └── create-game.sh             # Create new game from template
├── docs/
│   ├── SETUP.md                   # Detailed setup guide
│   ├── DEVELOPMENT.md             # Development guide
│   └── DEPLOYMENT.md              # Deployment guide
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

### Manual Deployment

```bash
# Set itch.io game URL (format: username/game-name)
export ITCH_GAME="johndoe/my-playdate-game"

# Deploy to dev channel
./scripts/deploy-itch.sh dev

# Deploy to beta channel
./scripts/deploy-itch.sh beta

# Deploy to stable channel (requires tag)
./scripts/deploy-itch.sh stable
```

### Automatic Deployment

Push to GitHub and let Actions handle it:

```bash
# Development deployment (push to main)
git add .
git commit -m "Add new feature"
git push origin main
# → Deploys to itch.io 'dev' channel

# Release deployment (create tag)
git tag v1.0.0
git push origin v1.0.0
# → Deploys to itch.io 'stable' channel
# → Creates GitHub release
```

## Development Guide

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

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Changelog

### v1.0.0 (Initial Release)
- ✅ Game template with basic structure
- ✅ Build scripts for simulator and device
- ✅ GitHub Actions CI/CD pipeline
- ✅ itch.io deployment automation
- ✅ Example game
- ✅ Comprehensive documentation

### Roadmap

- [ ] Automated testing framework
- [ ] Multi-language support
- [ ] Asset optimization pipeline
- [ ] Steam integration
- [ ] Analytics integration
- [ ] Performance profiling tools

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
