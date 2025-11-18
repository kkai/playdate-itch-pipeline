# Deployment Guide

Complete guide for deploying Playdate games to itch.io using this pipeline.

## Table of Contents

- [Overview](#overview)
- [Deployment Channels](#deployment-channels)
- [Setup](#setup)
- [Local Deployment](#local-deployment)
- [Automated Deployment (CI/CD)](#automated-deployment-cicd)
- [Release Process](#release-process)
- [Rollback Strategy](#rollback-strategy)
- [Troubleshooting](#troubleshooting)

## Overview

This pipeline supports three deployment channels to itch.io:

1. **Dev** - Automatic deploys from `main` branch (bleeding edge)
2. **Beta** - Tagged beta releases for testing (e.g., `v1.0.0-beta.1`)
3. **Stable** - Production releases (e.g., `v1.0.0`)

```
Code → Dev Channel → Beta Channel → Stable Channel → Players
       (main)        (beta tags)     (version tags)
```

## Deployment Channels

### Dev Channel (`playdate-dev`)

**Purpose:** Continuous deployment for internal testing

**Trigger:** Push to `main` branch

**Version:** Short git commit hash (e.g., `a1b2c3d`)

**Use Case:**
- Quick testing of new features
- Internal development builds
- Rapid iteration

**Visibility:** Private or restricted access recommended

```bash
# Manual deployment
./scripts/deploy-itch.sh dev
```

### Beta Channel (`playdate-beta`)

**Purpose:** Pre-release testing with wider audience

**Trigger:** Git tags matching `v*.*.*-beta.*`

**Version:** Full tag (e.g., `v1.0.0-beta.1`)

**Use Case:**
- Feature testing with beta testers
- Gathering feedback before stable release
- QA testing

**Visibility:** Can be public or restricted

**Creating a beta release:**
```bash
# Tag your commit
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1

# Or manually deploy
./scripts/deploy-itch.sh beta
```

### Stable Channel (`playdate-stable`)

**Purpose:** Production releases for all players

**Trigger:** Git tags matching `v*.*.*`

**Version:** Semantic version (e.g., `v1.0.0`)

**Use Case:**
- Final releases
- Public distribution
- Official versions

**Visibility:** Public

**Creating a stable release:**
```bash
# Tag your commit
git tag v1.0.0
git push origin v1.0.0

# Or manually deploy
./scripts/deploy-itch.sh stable
```

## Setup

### 1. itch.io Account

1. Create an account at [itch.io](https://itch.io/)
2. Go to [Create New Project](https://itch.io/game/new)
3. Fill in basic game information
4. Set **Kind of project** to "HTML" (for now)
5. Set **Visibility** as desired
6. Save the project

Note your game's URL: `username/game-name`

### 2. butler (itch.io CLI)

Install butler for command-line uploads:

**macOS:**
```bash
curl -L -o butler.zip https://broth.itch.ovh/butler/darwin-amd64/LATEST/archive/default
unzip butler.zip
chmod +x butler
sudo mv butler /usr/local/bin/
```

**Linux:**
```bash
curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
unzip butler.zip
chmod +x butler
sudo mv butler /usr/local/bin/
```

**Windows:**
```powershell
# Download from https://broth.itch.ovh/butler/windows-amd64/LATEST/archive/default
# Extract butler.exe to a folder in your PATH
```

### 3. API Key

1. Go to [itch.io API Keys](https://itch.io/user/settings/api-keys)
2. Click "Generate new API key"
3. Save the key securely

**Local setup:**
```bash
# Set in your shell profile (~/.bashrc, ~/.zshrc, etc.)
export BUTLER_API_KEY="your-api-key-here"
export ITCH_GAME="username/game-name"
```

**GitHub Actions setup:**

1. Go to your GitHub repository settings
2. Navigate to **Secrets and variables** → **Actions**
3. Add repository secrets:
   - `BUTLER_API_KEY`: Your itch.io API key
   - `ITCH_GAME`: Your game's itch.io identifier (`username/game-name`)

### 4. itch.io Channel Setup

Configure channels on itch.io:

1. Go to your game's dashboard
2. Navigate to **Edit game**
3. Scroll to **Uploads**
4. For each upload, you'll see the channel name
5. Recommended channel names:
   - `playdate-dev`
   - `playdate-beta`
   - `playdate-stable`

## Local Deployment

### Manual Build and Deploy

```bash
# 1. Build your game
./scripts/build.sh --source your-game

# 2. Validate the build
./scripts/validate.sh --source your-game

# 3. Test in simulator
./scripts/run-simulator.sh

# 4. Deploy to dev channel
./scripts/deploy-itch.sh dev

# 5. Deploy to beta channel
./scripts/deploy-itch.sh beta

# 6. Deploy to stable channel (with confirmation)
./scripts/deploy-itch.sh stable
```

### Dry Run

Test deployment without uploading:

```bash
./scripts/deploy-itch.sh dev --dry-run
```

This validates:
- Environment variables are set
- Build files exist
- butler is installed
- Command would execute correctly

## Automated Deployment (CI/CD)

### GitHub Actions Workflow

The pipeline automatically handles builds and deployments:

```yaml
main branch push → Build → Deploy to dev
beta tag push    → Build → Deploy to beta → Create pre-release
stable tag push  → Build → Deploy to stable → Create release
```

### Workflow File

Located at `.github/workflows/build-and-deploy.yml`

**Features:**
- Multi-platform builds (Linux, macOS, Windows)
- Artifact storage
- Automatic versioning
- GitHub releases
- itch.io uploads

### Triggering Automated Deployments

**Dev deployment:**
```bash
git add .
git commit -m "Add new feature"
git push origin main
```

**Beta deployment:**
```bash
git add .
git commit -m "Prepare beta release"
git tag v1.0.0-beta.1
git push origin main
git push origin v1.0.0-beta.1
```

**Stable deployment:**
```bash
git add .
git commit -m "Release v1.0.0"
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

### Monitoring Deployments

1. Go to your GitHub repository
2. Click **Actions** tab
3. View workflow runs
4. Check build logs
5. Download artifacts if needed

## Release Process

### Complete Release Workflow

#### 1. Development Phase

```bash
# Work on features
git checkout -b feature/awesome-feature
# ... make changes ...
git commit -m "Add awesome feature"
git push origin feature/awesome-feature

# Create PR
# After review and merge to main → auto-deploys to dev
```

#### 2. Beta Release

```bash
# Ensure main is up to date
git checkout main
git pull origin main

# Update version in pdxinfo
# Source/pdxinfo: version=1.0.0-beta.1

# Create beta tag
git add Source/pdxinfo
git commit -m "Bump version to 1.0.0-beta.1"
git tag v1.0.0-beta.1
git push origin main
git push origin v1.0.0-beta.1

# GitHub Actions will:
# 1. Build for all platforms
# 2. Deploy to playdate-beta channel
# 3. Create GitHub pre-release
```

#### 3. Testing Phase

- Test beta build on itch.io
- Gather feedback from beta testers
- Fix bugs, make improvements
- Create additional beta releases if needed (`v1.0.0-beta.2`, etc.)

#### 4. Stable Release

```bash
# Ensure all changes are merged
git checkout main
git pull origin main

# Update version in pdxinfo
# Source/pdxinfo: version=1.0.0

# Update CHANGELOG.md
# Add release notes

# Create release tag
git add Source/pdxinfo CHANGELOG.md
git commit -m "Release v1.0.0"
git tag v1.0.0
git push origin main
git push origin v1.0.0

# GitHub Actions will:
# 1. Build for all platforms
# 2. Deploy to playdate-stable channel
# 3. Create GitHub release
# 4. Attach build artifacts
```

#### 5. Post-Release

- Monitor itch.io analytics
- Watch for bug reports
- Plan next release

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):

**Format:** `MAJOR.MINOR.PATCH`

- **MAJOR:** Breaking changes (e.g., 2.0.0)
- **MINOR:** New features (e.g., 1.1.0)
- **PATCH:** Bug fixes (e.g., 1.0.1)

**Beta versions:** `MAJOR.MINOR.PATCH-beta.NUMBER`
- Example: `1.0.0-beta.1`, `1.0.0-beta.2`

**Examples:**
```
1.0.0-beta.1  → First beta of 1.0.0
1.0.0-beta.2  → Second beta of 1.0.0
1.0.0         → Stable release
1.0.1         → Bug fix release
1.1.0         → New feature release
2.0.0         → Major version with breaking changes
```

## Rollback Strategy

### If a bad build is deployed

#### Option 1: Deploy Previous Version

```bash
# Find previous good tag
git tag -l

# Deploy that version manually
git checkout v1.0.0
./scripts/build.sh --source your-game
./scripts/deploy-itch.sh stable

# Or create a new tag from old commit
git tag v1.0.2 <old-commit-hash>
git push origin v1.0.2
```

#### Option 2: itch.io Dashboard

1. Go to your game's dashboard on itch.io
2. Navigate to **Edit game** → **Upload**
3. Find the channel with the bad build
4. Click "Delete" on the problematic version
5. Previous version becomes active again

#### Option 3: Quick Fix Release

```bash
# Make fixes
git add .
git commit -m "Hotfix: Critical bug fix"

# Create patch version
git tag v1.0.1
git push origin v1.0.1

# CI/CD will automatically deploy
```

### If GitHub Actions fails

1. Check the Actions tab for error logs
2. Common issues:
   - Missing secrets
   - SDK download failure
   - Build errors
3. Fix the issue
4. Re-run the workflow or push a new commit

## Troubleshooting

### butler login fails

**Problem:** "Authentication failed"

**Solution:**
```bash
# Check API key is set
echo $BUTLER_API_KEY

# If not set
export BUTLER_API_KEY="your-api-key-here"

# Test login
butler login
```

### Wrong channel deployed

**Problem:** Deployed to wrong itch.io channel

**Solution:**
```bash
# Deploy to correct channel
./scripts/deploy-itch.sh <correct-channel>

# Or use butler directly
butler push build/YourGame.pdx username/game-name:correct-channel
```

### Build not found

**Problem:** "Error: Build file not found"

**Solution:**
```bash
# Build the game first
./scripts/build.sh --source your-game

# Verify build exists
ls -la build/

# Then deploy
./scripts/deploy-itch.sh dev
```

### Version mismatch

**Problem:** Git tag doesn't match pdxinfo version

**Solution:**
- Keep pdxinfo version in sync with git tags
- Update both when releasing

```bash
# Update pdxinfo
# Source/pdxinfo: version=1.0.0

# Create matching tag
git tag v1.0.0
```

### GitHub Actions secrets not set

**Problem:** Workflow fails with "secret not found"

**Solution:**
1. Go to repository **Settings**
2. **Secrets and variables** → **Actions**
3. Add missing secrets:
   - `BUTLER_API_KEY`
   - `ITCH_GAME`

### Multi-game deployment

**Problem:** Need to deploy multiple games from one repo

**Solution:**

Modify `deploy-itch.sh`:
```bash
# Pass game name and itch.io identifier
./scripts/deploy-itch.sh dev --source game1 --itch username/game1
./scripts/deploy-itch.sh dev --source game2 --itch username/game2
```

Or use separate workflows for each game.

### Channel visibility

**Problem:** Can't find uploaded channel on itch.io

**Solution:**
1. Go to game dashboard
2. **Edit game** → **Uploads**
3. Click on the upload
4. Set visibility and download options
5. Save

### Download links

**Problem:** Players can't find download

**Solution:**
1. Ensure game is published (not draft)
2. Set pricing (free or paid)
3. Enable downloads on game page
4. Share direct link: `https://username.itch.io/game-name`

## Best Practices

### 1. Testing Before Release

✅ Always test beta versions before stable release

```bash
# Build
./scripts/build.sh

# Validate
./scripts/validate.sh

# Test in simulator
./scripts/run-simulator.sh

# Deploy to beta
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1

# Test beta build on itch.io
# Then promote to stable
```

### 2. Changelog Maintenance

Keep `CHANGELOG.md` updated:

```markdown
# Changelog

## [1.0.0] - 2024-01-15

### Added
- New enemy type
- Boss battle

### Changed
- Improved collision detection

### Fixed
- Menu navigation bug
```

### 3. Release Notes

Use descriptive release notes:

```bash
# Good
git tag -a v1.0.0 -m "Release 1.0.0: Adds boss battles and fixes menu bugs"

# Basic
git tag v1.0.0
```

### 4. Pre-deployment Checklist

- [ ] Code builds without errors
- [ ] Validation passes
- [ ] Tested in simulator
- [ ] Version updated in pdxinfo
- [ ] CHANGELOG.md updated
- [ ] Git tag matches version
- [ ] Beta tested (for stable releases)

### 5. Communication

- Announce releases to your community
- Share release notes on social media
- Engage with player feedback
- Update game description on itch.io

## Monitoring

### itch.io Analytics

View deployment success:

1. Game dashboard → **Analytics**
2. Check downloads per channel
3. Monitor player feedback
4. Track download trends

### GitHub Actions

Monitor build health:

1. Repository → **Actions**
2. Review workflow runs
3. Check build times
4. Download artifacts for testing

### Version Tracking

```bash
# List all releases
git tag -l

# Show release details
git show v1.0.0

# See what's deployed
butler status username/game-name
```

## Advanced Topics

### Custom Channels

Create additional channels:

```bash
# Deploy to custom channel
butler push build/Game.pdx username/game-name:experimental-v1.2
```

### Multi-platform Builds

Deploy platform-specific builds:

```bash
# Linux build
butler push build/Game.pdx username/game-name:linux-stable

# macOS build
butler push build/Game.pdx username/game-name:mac-stable
```

### Automated Changelog

Generate changelog from commits:

```bash
# Install tool
npm install -g conventional-changelog-cli

# Generate changelog
conventional-changelog -p angular -i CHANGELOG.md -s
```

## Resources

- [itch.io Documentation](https://itch.io/docs/creators/)
- [butler Documentation](https://itch.io/docs/butler/)
- [Semantic Versioning](https://semver.org/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

## Next Steps

1. Set up your itch.io game page
2. Configure GitHub secrets
3. Test the deployment pipeline
4. Create your first release!

---

Happy deploying! 🚀
