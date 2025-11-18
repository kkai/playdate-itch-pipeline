# Example Games

This directory contains complete, production-ready example games that demonstrate the Playdate itch.io Pipeline and showcase best practices for Playdate development.

## Available Examples

### 🧱 [Breakout](breakout/)

Classic brick-breaking game with crank-controlled paddle.

**Features:**
- Smooth crank-based paddle control
- Multiple brick types with hit points
- Particle effects and screen shake
- Progressive difficulty
- High score persistence
- State management (menu, playing, game over)

**Demonstrates:**
- Crank input handling
- Physics and collision detection
- Particle systems
- Visual effects (screen shake)
- Data persistence
- Game state management

**Difficulty:** Medium
**Lines of Code:** ~600
**Estimated Dev Time:** 4-6 hours

[View Breakout README →](breakout/README.md)

---

## Building Examples

### Using Make

```bash
# Build any example
make build GAME_SOURCE=examples/breakout

# Validate code
make validate GAME_SOURCE=examples/breakout

# Run in simulator
make run
```

### Using Scripts

```bash
# Build for simulator
./scripts/build.sh --source examples/breakout

# Build for device
./scripts/build.sh --source examples/breakout --device

# Run in simulator
./scripts/run-simulator.sh
```

## Deploying Examples

You can deploy these examples to itch.io using the pipeline:

```bash
# Set your itch.io game
export ITCH_GAME="yourusername/breakout-playdate"

# Deploy to dev channel
./scripts/deploy-itch.sh dev

# Or create a release
git tag v1.0.0
git push origin v1.0.0
```

## Learning Path

### Beginner
Start with understanding:
1. Basic Playdate API structure
2. Game loop (playdate.update)
3. Input handling (buttons, crank)
4. Drawing functions

### Intermediate
Study these examples to learn:
1. **Breakout** - Physics, collisions, state management
2. Game state patterns
3. Visual effects and polish
4. Data persistence

### Advanced
Extend the examples with:
1. Sound effects and music
2. Multiple levels with custom layouts
3. Power-up systems
4. Leaderboards
5. Custom graphics and animations

## Code Quality

All examples follow best practices:
- ✅ Proper CoreLibs imports
- ✅ Correct lifecycle callbacks
- ✅ Comprehensive comments
- ✅ Clean code organization
- ✅ Const declarations for performance
- ✅ Validation-ready (passes `make validate`)

## Contributing Examples

Want to contribute an example game? We'd love to see:

- **Classic games** adapted for Playdate
- **Unique crank mechanics** demonstrations
- **Different genres** (puzzle, platformer, RPG, etc.)
- **Advanced techniques** (3D, custom rendering, etc.)

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## Roadmap

Planned future examples:
- [ ] **Snake** - Simple game with crank turn controls
- [ ] **Pong** - Two-player with crank paddles
- [ ] **Space Invaders** - Wave-based shooter
- [ ] **Tetris** - Block-falling puzzle with crank rotation
- [ ] **Fishing** - Creative crank usage as reel
- [ ] **Platformer** - Side-scrolling action
- [ ] **Puzzle** - Grid-based logic game

## Resources

- [Playdate SDK Documentation](https://sdk.play.date/)
- [Development Guide](../docs/DEVELOPMENT.md)
- [Deployment Guide](../docs/DEPLOYMENT.md)
- [Main Pipeline README](../README.md)

---

**Happy coding!** 🎮✨
