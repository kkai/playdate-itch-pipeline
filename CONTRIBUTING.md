# Contributing to Playdate itch.io Pipeline

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Submitting Changes](#submitting-changes)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors.

### Expected Behavior

- Be respectful and considerate
- Welcome newcomers and help them learn
- Accept constructive criticism gracefully
- Focus on what's best for the project and community

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Personal attacks or trolling
- Publishing others' private information
- Other conduct that would be inappropriate in a professional setting

## Getting Started

### Prerequisites

1. **Git** - Version control
2. **Playdate SDK** - For testing game builds
3. **bash** - For running scripts
4. **Text Editor** - VS Code, Sublime Text, etc.

### Setup

```bash
# Fork the repository on GitHub

# Clone your fork
git clone https://github.com/YOUR_USERNAME/playdate-itch-pipeline.git
cd playdate-itch-pipeline

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/playdate-itch-pipeline.git

# Install git hooks
./scripts/install-hooks.sh

# Set up Playdate SDK
export PLAYDATE_SDK_PATH="/path/to/PlaydateSDK"
```

## How to Contribute

### Types of Contributions

We welcome many types of contributions:

1. **Bug Fixes** - Fix issues in scripts or workflows
2. **New Features** - Add new functionality to the pipeline
3. **Documentation** - Improve or expand documentation
4. **Examples** - Add example games or templates
5. **Testing** - Help test builds on different platforms
6. **Scripts** - Improve build or deployment scripts
7. **CI/CD** - Enhance GitHub Actions workflows

### Areas for Contribution

- **Scripts**: Build, deploy, validation scripts
- **Documentation**: Guides, tutorials, API docs
- **CI/CD**: GitHub Actions improvements
- **Templates**: Game templates and examples
- **Tools**: Developer utilities and helpers
- **Tests**: Validation and testing infrastructure

## Development Workflow

### 1. Create a Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### Branch Naming

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Test additions or changes

### 2. Make Changes

- Write clear, readable code
- Follow existing code style
- Add comments for complex logic
- Update documentation as needed

### 3. Test Your Changes

```bash
# Run validation
./scripts/validate.sh

# Test builds
./scripts/build.sh --source game-template

# Test in simulator
./scripts/run-simulator.sh

# Test deployment (dry run)
./scripts/deploy-itch.sh dev --dry-run
```

### 4. Commit Changes

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: add new deployment channel"
```

#### Commit Message Format

Use conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(deploy): add beta channel support

Add support for deploying to beta channel via git tags.
Beta releases are marked as pre-releases on GitHub.

Closes #123
```

```
fix(build): resolve Windows path handling

Fix path separator issues on Windows platform in build.sh.

Fixes #456
```

```
docs(readme): update installation instructions

Add more detailed steps for macOS setup.
```

### 5. Push and Create PR

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create Pull Request on GitHub
# Fill out the PR template
```

## Coding Standards

### Shell Scripts

```bash
#!/bin/bash

# Use strict mode
set -e

# Use meaningful variable names
PLAYDATE_SDK_PATH="/path/to/sdk"

# Add comments for complex logic
# This function validates the build output
validate_build() {
    local build_dir=$1
    # ...
}

# Use functions for reusability
main() {
    # Main logic here
}

main "$@"
```

### Best Practices

1. **Error Handling**
   - Always check for errors
   - Provide helpful error messages
   - Use `set -e` to exit on error

2. **Cross-Platform**
   - Test on Linux, macOS, and Windows
   - Use portable commands
   - Handle path differences

3. **Documentation**
   - Document all functions
   - Add usage examples
   - Keep README updated

4. **Security**
   - Never commit API keys or secrets
   - Use environment variables
   - Validate user input

## Submitting Changes

### Pull Request Checklist

Before submitting a PR, ensure:

- [ ] Code follows project style
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated
- [ ] Commit messages are clear
- [ ] PR description explains changes
- [ ] Related issues are linked

### PR Review Process

1. **Automated Checks** - GitHub Actions runs tests
2. **Code Review** - Maintainers review your code
3. **Feedback** - Address any requested changes
4. **Approval** - Once approved, PR will be merged
5. **Cleanup** - Delete your branch after merge

### What to Expect

- **Response Time**: Usually within 2-3 days
- **Review Time**: Depends on PR complexity
- **Feedback**: We may request changes or ask questions
- **Merge**: Approved PRs are merged by maintainers

## Reporting Bugs

### Before Reporting

1. **Search** existing issues to avoid duplicates
2. **Test** on the latest version
3. **Isolate** the problem
4. **Gather** relevant information

### Bug Report Template

Use the bug report template when creating an issue:

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: macOS 14.0
- SDK Version: 2.4.1
- Pipeline Version: main@abc123

## Error Messages
```
paste error messages
```
```

## Suggesting Features

### Feature Request Template

Use the feature request template:

```markdown
## Feature Description
What feature would you like?

## Problem This Solves
Why is this needed?

## Proposed Solution
How should it work?

## Alternatives Considered
Other approaches considered

## Example Use Case
Concrete example of usage
```

### Feature Discussion

- Features are discussed before implementation
- Feedback from community is encouraged
- Major features may require design docs

## Development Tips

### Local Testing

```bash
# Create test game
./scripts/create-game.sh "Test Game" "Test Author"

# Build and validate
./scripts/build.sh --source test-game
./scripts/validate.sh --source test-game

# Test simulator
./scripts/run-simulator.sh
```

### Debugging Scripts

```bash
# Run with debug output
bash -x ./scripts/build.sh

# Add debug prints
echo "DEBUG: Variable value is: $VARIABLE"
```

### Testing CI/CD

- Fork the repo to test GitHub Actions
- Use workflow_dispatch for manual testing
- Check Actions tab for build logs

## Resources

### Documentation

- [Playdate SDK Docs](https://sdk.play.date/)
- [itch.io butler Docs](https://itch.io/docs/butler/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

### Community

- [Playdate Developer Forum](https://devforum.play.date/)
- [Playdate Squad Discord](https://discord.gg/playdate)

### Tools

- [shellcheck](https://www.shellcheck.net/) - Shell script linter
- [luacheck](https://github.com/mpeterv/luacheck) - Lua linter

## Recognition

Contributors are recognized in several ways:

- Listed in README acknowledgments
- Mentioned in release notes
- GitHub contributor badge

## Questions?

If you have questions:

1. Check existing documentation
2. Search closed issues
3. Ask in discussions
4. Open a new issue

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

Thank you for contributing! 🎮✨
