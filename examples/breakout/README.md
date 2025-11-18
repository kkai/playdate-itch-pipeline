# Breakout - Example Game

A complete implementation of the classic brick-breaking game for Playdate, showcasing the pipeline's capabilities and demonstrating best practices.

## Features

### Core Gameplay
- **Crank-controlled paddle** with smooth analog movement
- **Physics-based ball** with realistic bouncing
- **Multiple brick types** with different hit points (1-3 hits)
- **Progressive difficulty** - speed increases with each level
- **Lives system** - Start with 3 lives
- **High score tracking** - Persistent across sessions

### Visual Polish
- **Particle effects** when bricks break
- **Screen shake** on impacts for tactile feedback
- **Dithering patterns** to show brick damage states
- **Smooth animations** with lerped paddle movement

### Game States
- **Menu** - Title screen with instructions and high score
- **Playing** - Main gameplay with score and lives display
- **Game Over** - Final score and restart option

### Controls
- **Crank** - Move paddle left/right (primary control)
- **D-Pad Left/Right** - Alternative paddle control
- **A Button** - Launch ball / Start game / Restart
- **B Button** - Toggle FPS display

## Code Structure

### Main Components

```lua
-- Game Objects
paddle       -- Player-controlled paddle
ball         -- Bouncing ball
bricks[]     -- Array of breakable bricks
particles[]  -- Particle system for effects

-- Game States
STATE_MENU
STATE_PLAYING
STATE_GAME_OVER

-- Core Systems
updatePaddle()           -- Crank and D-pad input
updateBall()             -- Physics and movement
checkBrickCollisions()   -- Collision detection
updateParticles()        -- Particle effects
updateScreenShake()      -- Camera shake
```

### Key Features Demonstrated

1. **Crank Input**
   ```lua
   local crankChange = playdate.getCrankChange()
   paddle.targetX += crankChange * 2
   ```

2. **Smooth Movement**
   ```lua
   paddle.x += (paddle.targetX - paddle.x) * 0.3
   ```

3. **Collision Detection**
   - Ball vs. Walls
   - Ball vs. Paddle (with spin based on hit position)
   - Ball vs. Bricks (with side detection)

4. **Particle System**
   - Spawned on brick destruction
   - Gravity simulation
   - Lifetime management

5. **Screen Shake**
   - Intensity-based effect
   - Exponential decay
   - Random offset calculation

6. **State Management**
   - Clean separation of menu, gameplay, and game over
   - Persistent high score using `playdate.datastore`

7. **Lifecycle Management**
   - Save on device lock
   - Save on game terminate
   - Proper initialization

## Building and Running

### Using Make

```bash
# Build the game
make build GAME_SOURCE=examples/breakout

# Validate
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

## Gameplay Tips

1. **Use the Crank** - The crank provides more precise control than the D-pad
2. **Aim Your Shots** - Hit the ball with the edge of the paddle to add spin
3. **Watch the Speed** - Ball speed increases slightly with each paddle hit
4. **Plan Ahead** - Some bricks require multiple hits (shown by dithering)
5. **Complete Levels** - Clear all bricks to advance to the next level

## Technical Highlights

### Physics
- Vector-based ball movement
- Angle calculation for paddle reflections
- Speed limiting to prevent excessive velocity
- Spin mechanics based on paddle hit position

### Performance
- Efficient collision detection (early exits)
- Particle pooling concept (can be optimized further)
- Draw call optimization
- Minimal garbage collection

### Visual Design
- 1-bit graphics optimized for Playdate's screen
- Dithering patterns for visual variety
- Clear UI with score, lives, and level display
- Readable text positioning

## Customization Ideas

Want to extend the game? Try these:
- **Power-ups**: Multi-ball, paddle size, slow-mo
- **More brick types**: Moving bricks, unbreakable bricks
- **Sounds**: Add ball bounce, brick break, level complete sounds
- **Levels**: Design custom brick layouts
- **Animations**: Animated brick destruction
- **Juice**: More particle effects, color flashes (using dithering)

## Learning Points

This example demonstrates:
- ✅ Proper CoreLibs imports
- ✅ Correct lifecycle callbacks
- ✅ Crank input handling
- ✅ Button input (pressed vs. just pressed)
- ✅ Vector math for physics
- ✅ AABB collision detection
- ✅ State machine pattern
- ✅ Particle system basics
- ✅ Screen effects (shake)
- ✅ Data persistence
- ✅ Clean code organization
- ✅ Comprehensive comments

## Credits

- **Original Game**: Atari's Breakout (1976)
- **Implementation**: Playdate Pipeline Example
- **Inspired By**: Classic arcade games and modern indie interpretations

## License

This example is part of the Playdate itch.io Pipeline project and is licensed under the MIT License.

---

**Have fun breaking bricks!** 🧱💥

For more information about the pipeline, see the [main README](../../README.md).
