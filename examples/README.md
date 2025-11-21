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

### 🐍 [Snake](snake/)

Classic snake game with unique crank-based turning mechanic.

**Features:**
- Innovative crank turning (rotate to turn snake)
- Grid-based movement with smooth animations
- Progressive difficulty (speed increases)
- Classic eat-and-grow gameplay
- Clean retro grid aesthetic
- High score persistence

**Demonstrates:**
- Grid-based game design
- Unique crank control scheme
- Animation interpolation
- Timer-based movement
- Direction management
- Array manipulation
- Collision detection in grids

**Difficulty:** Easy
**Lines of Code:** ~520
**Estimated Dev Time:** 3-4 hours

[View Snake README →](snake/README.md)

---

### 🏓 [Pong](pong/)

Classic table tennis with AI opponent and two-player mode.

**Features:**
- Single player vs adaptive AI
- Two-player local multiplayer
- Crank-controlled paddle (Player 1)
- Ball angle reflection physics
- Progressive AI difficulty
- Classic court design

**Demonstrates:**
- AI opponent with ball prediction
- Multiplayer game structure
- Adaptive difficulty
- Ball physics and angles
- Menu system with mode selection
- Crank analog control

**Difficulty:** Easy
**Lines of Code:** ~520
**Estimated Dev Time:** 3-4 hours

[View Pong README →](pong/README.md)

---

### 👾 [Space Invaders](space-invaders/)

Classic arcade wave-based shooter with destructible shields.

**Features:**
- Crank-controlled ship movement
- Three alien types with different point values
- Pixel-based destructible shields
- Mystery UFO bonus ship
- Wave progression with increasing difficulty
- High score persistence

**Demonstrates:**
- Wave-based game design
- Pixel-perfect shield destruction
- Column-based AI shooting
- Adaptive difficulty scaling
- Animated alien sprites
- Multiple entity management
- Particle explosions

**Difficulty:** Medium
**Lines of Code:** ~700
**Estimated Dev Time:** 4-6 hours

[View Space Invaders README →](space-invaders/README.md)

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
Start with **Snake** - easier implementation, core concepts:
1. Basic Playdate API structure
2. Game loop (playdate.update)
3. Grid-based movement
4. Crank input handling
5. Timer-based updates
6. Simple collision detection

### Intermediate
Move to **Breakout** for advanced topics:
1. Physics and vector math
2. AABB collision detection
3. Particle systems
4. Visual effects (screen shake)
5. Game state patterns
6. Data persistence

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

**Completed:**
- [x] **Breakout** - Physics-based brick breaker
- [x] **Snake** - Grid-based crank turning
- [x] **Pong** - Two-player with AI opponent
- [x] **Space Invaders** - Wave-based shooter

**Planned future examples:**
- [ ] **Tetris** - Block-falling puzzle with crank rotation
- [ ] **Fishing** - Creative crank usage as reel
- [ ] **Platformer** - Side-scrolling action
- [ ] **Puzzle** - Grid-based logic game
- [ ] **RPG Battle** - Turn-based combat demo

## Resources

- [Playdate SDK Documentation](https://sdk.play.date/)
- [Development Guide](../docs/DEVELOPMENT.md)
- [Deployment Guide](../docs/DEPLOYMENT.md)
- [Main Pipeline README](../README.md)

---

**Happy coding!** 🎮✨
