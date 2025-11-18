# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Beta channel deployment support for testing releases
- Comprehensive validation script with 9 categories of checks
- Pre-commit hooks for code quality enforcement
- GitHub issue templates (bug report, feature request, game showcase)
- Pull request template for consistent contributions
- DEVELOPMENT.md - Complete development guide
- DEPLOYMENT.md - Comprehensive deployment documentation
- CONTRIBUTING.md - Contribution guidelines
- Makefile for simplified command execution
- Example assets directory structure in game template
- Pre-push hook warning for main branch pushes
- Commit message validation hook

### Changed
- Enhanced CI/CD workflow to support dev, beta, and stable channels
- Improved error handling in deployment scripts
- Updated README with new features and capabilities

### Fixed
- Stable release deployment now excludes beta tags

## [1.0.0] - 2024-XX-XX

### Added
- Initial release of Playdate to itch.io deployment pipeline
- Multi-platform CI/CD with GitHub Actions (Linux, macOS, Windows)
- Automated deployment to itch.io using butler
- Build scripts for Playdate SDK
- Game template with working example
- Comprehensive README and SETUP documentation
- Cross-platform build support
- Git tag-based versioning
- Development and stable deployment channels
- Playdate Simulator integration
- Game scaffolding script

### Features
- Automated builds on push to main
- Version tag-based stable releases
- GitHub release creation with artifacts
- itch.io channel management
- Build validation and testing
- Lua syntax checking
- Multi-game support

---

## Release Types

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** in case of vulnerabilities

## Version Numbering

This project follows semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR** version for incompatible API changes
- **MINOR** version for added functionality in a backwards compatible manner
- **PATCH** version for backwards compatible bug fixes

Beta versions are denoted as: `MAJOR.MINOR.PATCH-beta.NUMBER`
