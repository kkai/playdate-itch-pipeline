# Snake - Example Game

A classic Snake game with a unique crank-based turning mechanic for Playdate. This example demonstrates grid-based gameplay, smooth animations, and innovative control schemes.

## Features

### Core Gameplay
- **Unique crank turning** - Rotate crank clockwise/counter-clockwise to turn
- **Grid-based movement** with smooth interpolated animations
- **Classic snake mechanics** - eat food, grow longer, avoid walls and yourself
- **Progressive difficulty** - speed increases as you eat more food
- **High score tracking** - Persistent across sessions

### Visual Design
- **Clean grid aesthetic** - Minimalist retro look
- **Smooth animations** - Interpolated movement between grid cells
- **Snake head with eyes** - Direction-aware visual feedback
- **Food rendering** - Circle with highlight effect

### Controls
- **Crank** - Rotate clockwise to turn right, counter-clockwise to turn left (primary)
- **D-Pad** - Alternative directional control
- **A Button** - Start game / Restart
- **B Button** - Toggle FPS display

### Game States
- **Menu** - Title screen with instructions and high score
- **Playing** - Main gameplay with score, length, and speed display
- **Game Over** - Final stats with restart option

## Unique Crank Mechanic

The crank controls are designed to feel natural and responsive:

```lua
-- Crank rotation detection
local crankPosition = playdate.getCrankPosition()
local crankChange = crankPosition - lastCrankPosition

if crankChange > crankTurnThreshold then
    -- Cranked clockwise → turn right
    turnRight()
elseif crankChange < -crankTurnThreshold then
    -- Cranked counter-clockwise → turn left
    turnLeft()
end
```

**Why this works:**
- Mimics a physical steering wheel
- Clear 1:1 mapping (crank rotation = snake turning)
- Threshold prevents accidental turns
- Handles 360° wraparound correctly

## Code Structure

### Main Components

```lua
-- Game Objects
snake[]      -- Array of {x, y, prevX, prevY} segments
food         -- {x, y} position on grid
moveTimer    -- Controls snake movement speed

-- Grid System
GRID_SIZE = 10           -- 10x10 pixel cells
GRID_WIDTH = 40          -- 40 cells wide
GRID_HEIGHT = 24         -- 24 cells tall

-- Core Systems
handleInput()            -- Crank and D-pad input
moveSnake()              -- Update snake position
spawnFood()              -- Random food placement
drawGrid()               -- Render grid lines
drawSnake()              -- Render snake with animation
```

### Key Features Demonstrated

1. **Grid-Based Movement**
   ```lua
   function gridToScreen(gridX, gridY)
       return gridX * GRID_SIZE, gridY * GRID_SIZE
   end
   ```

2. **Smooth Animation**
   ```lua
   -- Interpolate between grid positions
   local t = math.min(animationProgress, 1.0)
   local x = prevX + (currentX - prevX) * t
   ```

3. **Crank Input with Wraparound**
   ```lua
   -- Handle 360° to 0° transition
   if crankChange > 180 then
       crankChange -= 360
   elseif crankChange < -180 then
       crankChange += 360
   end
   ```

4. **Direction Management**
   ```lua
   -- Prevent 180° turns
   function isOppositeDirection(dir1, dir2)
       return (dir1 + 2) % 4 == dir2
   end
   ```

5. **Timer-Based Movement**
   ```lua
   moveTimer = playdate.timer.new(currentSpeed, function()
       moveSnake()
   end)
   moveTimer.repeats = true
   ```

6. **Collision Detection**
   - Wall collision (grid bounds)
   - Self collision (check all segments)
   - Food collision (exact position match)

7. **Progressive Difficulty**
   ```lua
   -- Speed up every 5 food (50 points)
   if score % 50 == 0 and currentSpeed > MAX_SPEED then
       currentSpeed -= 10
   end
   ```

## Building and Running

### Using Make

```bash
# Build the game
make build GAME_SOURCE=examples/snake

# Validate
make validate GAME_SOURCE=examples/snake

# Run in simulator
make run
```

### Using Scripts

```bash
# Build for simulator
./scripts/build.sh --source examples/snake

# Build for device
./scripts/build.sh --source examples/snake --device

# Run in simulator
./scripts/run-simulator.sh
```

## Gameplay Tips

1. **Use the Crank** - The crank provides more intuitive turning than D-pad
2. **Plan Ahead** - Think about your path before you get there
3. **Use the Edges** - Spiral patterns work well for collecting food
4. **Watch Your Tail** - As you grow, avoid boxing yourself in
5. **Speed Management** - Game gets faster as you eat more food

## Technical Highlights

### Grid System
- Converts between grid coordinates and screen pixels
- Validates positions against grid bounds
- Efficient collision detection using grid positions

### Animation System
- Stores previous position for each segment
- Linear interpolation for smooth movement
- Progress value (0 to 1) controls animation

### Input Handling
- Dual control scheme (crank + D-pad)
- Direction queuing (next turn stored)
- Opposite direction prevention

### Performance
- Simple array-based snake representation
- Efficient food spawning with attempt limit
- Timer-based movement (not per-frame)
- Minimal garbage collection

## Customization Ideas

Want to extend the game? Try these:

- **Power-ups**: Speed boost, slow-mo, invincibility
- **Obstacles**: Walls, moving blocks, teleporters
- **Game modes**: Time trial, endless, maze
- **Visual effects**: Trail effects, food animations
- **Sounds**: Movement, eating, collision sounds
- **Difficulty levels**: Different starting speeds
- **Multiplayer**: Two snakes on same screen
- **Patterns**: Pre-designed levels with challenges

## Learning Points

This example demonstrates:
- ✅ Grid-based game design
- ✅ Unique crank control implementation
- ✅ Animation interpolation techniques
- ✅ Timer-based game loops
- ✅ Direction management and validation
- ✅ Collision detection in grid systems
- ✅ Progressive difficulty scaling
- ✅ Array manipulation (snake segments)
- ✅ Food spawning algorithms
- ✅ Clean state machine pattern
- ✅ High score persistence

## Comparison to Breakout

| Aspect | Snake | Breakout |
|--------|-------|----------|
| **Difficulty** | Easy | Medium |
| **Lines of Code** | ~520 | ~600 |
| **Control Type** | Discrete turns | Continuous movement |
| **Gameplay** | Grid-based | Physics-based |
| **Collision** | Grid positions | AABB rectangles |
| **Best For** | Learning grids | Learning physics |

## Credits

- **Original Game**: Classic Snake (1976)
- **Implementation**: Playdate Pipeline Example
- **Inspired By**: Nokia Snake, Nibbler, various snake games

## License

This example is part of the Playdate itch.io Pipeline project and is licensed under the MIT License.

---

**Eat, grow, and don't crash!** 🐍

For more information about the pipeline, see the [main README](../../README.md).
