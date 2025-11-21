# Pong - Example Game

The original video game classic, reimagined for Playdate with crank-controlled paddles and intelligent AI opponent.

## Features

### Game Modes
- **1 Player vs CPU** - Challenge an adaptive AI opponent
- **2 Players Local** - Face off against a friend

### Core Gameplay
- **Crank-controlled paddle** for Player 1 with smooth analog movement
- **D-pad control** for Player 2 (or alternative P1 control)
- **Progressive AI** that adapts to your skill level
- **Classic scoring** - First to 11 wins
- **Ball physics** with angle reflection based on paddle hit position

### Visual Design
- **Classic court layout** with dashed center line
- **Screen flash** on paddle hits for feedback
- **Ball blinking** before serve
- **Clean score display** with player labels

### Controls

| Input | Action |
|-------|--------|
| **Crank** | Move P1 paddle up/down |
| **D-Pad Up/Down** | Move P2 paddle (or P1 alternative) |
| **A Button** | Select mode / Serve / Restart |
| **B Button** | Back to menu |

## AI Opponent

The CPU opponent features adaptive difficulty:

```lua
-- AI predicts ball trajectory
function predictBallY()
    local timeToReach = (paddle2.x - ball.x) / ball.vx
    local predictedY = ball.y + ball.vy * timeToReach
    -- Account for wall bounces...
    return predictedY
end

-- AI adds controlled imperfection
local error = (1 - aiDifficulty) * PADDLE_HEIGHT * 2
aiTargetY += (math.random() - 0.5) * error
```

**AI Features:**
- Ball trajectory prediction with bounce calculation
- Reaction time delay (faster at higher difficulty)
- Controlled imperfection for fair gameplay
- Difficulty increases after each point you score

## Code Structure

### Main Components

```lua
-- Game Objects
paddle1, paddle2    -- Player paddles with position and score
ball               -- Ball with position, velocity, speed

-- Game Modes
MODE_1P            -- Single player vs AI
MODE_2P            -- Two-player local

-- Core Systems
handlePlayer1Input()   -- Crank and D-pad input
handlePlayer2Input()   -- D-pad or AI control
updateAI()             -- AI prediction and movement
updateBall()           -- Physics and collision
```

### Key Features Demonstrated

1. **Crank Paddle Control**
   ```lua
   local crankChange = playdate.getCrankChange()
   paddle1.targetY += crankChange * 1.5
   ```

2. **Ball Angle Reflection**
   ```lua
   -- Angle based on where ball hits paddle
   local hitPos = (ball.y - paddle.y) / (PADDLE_HEIGHT / 2)
   ball.vy = hitPos * ball.speed * 0.8
   ```

3. **AI Ball Prediction**
   - Calculates time for ball to reach paddle
   - Predicts Y position accounting for bounces
   - Adds controlled error for fairness

4. **Velocity Normalization**
   ```lua
   -- Keep ball at consistent speed
   local currentSpeed = math.sqrt(vx*vx + vy*vy)
   ball.vx = (ball.vx / currentSpeed) * ball.speed
   ball.vy = (ball.vy / currentSpeed) * ball.speed
   ```

5. **Smooth Paddle Movement**
   ```lua
   -- Lerp toward target position
   paddle.y += (paddle.targetY - paddle.y) * 0.3
   ```

6. **Screen Flash Effect**
   ```lua
   if screenFlash > 0 and screenFlash % 2 == 0 then
       gfx.fillRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
   end
   ```

## Building and Running

### Using Make

```bash
# Build the game
make build GAME_SOURCE=examples/pong

# Validate
make validate GAME_SOURCE=examples/pong

# Run in simulator
make run
```

### Using Scripts

```bash
./scripts/build.sh --source examples/pong
./scripts/run-simulator.sh
```

## Gameplay Tips

### Single Player
1. **Use the crank** - More precise control than D-pad
2. **Watch the angle** - Ball bounces based on paddle hit position
3. **Center hits** go straight, edge hits angle sharply
4. **AI adapts** - It gets better as you score, stay focused!

### Two Player
1. **P1 uses crank**, P2 uses D-pad
2. **Communicate** - Call out when you're about to hit
3. **Mix up angles** - Keep your opponent guessing

## Technical Highlights

### Physics System
- Simple 2D ball movement
- Wall reflection (top/bottom)
- Paddle collision with angle calculation
- Progressive speed increase

### AI System
- Trajectory prediction algorithm
- Bounce calculation for accuracy
- Adaptive difficulty scaling
- Reaction time simulation

### Performance
- Minimal draw calls
- Efficient collision detection
- No sprite overhead (direct drawing)
- Timer-based updates

## Customization Ideas

- **Power-ups**: Speed boost, paddle size changes
- **Multiple balls**: Chaos mode
- **Obstacles**: Blocks in the middle
- **Different court shapes**: Circular, angled walls
- **Sound effects**: Paddle hits, scoring, ambient
- **Tournament mode**: Best of 3/5/7 matches
- **Network multiplayer**: Using Playdate's wireless features

## Learning Points

This example demonstrates:
- ✅ Menu system with mode selection
- ✅ Two-player local multiplayer
- ✅ AI opponent with prediction
- ✅ Adaptive difficulty
- ✅ Ball physics and angles
- ✅ Crank analog control
- ✅ Visual feedback effects
- ✅ Score tracking
- ✅ Game state management
- ✅ Classic game recreation

## Comparison to Other Examples

| Aspect | Pong | Breakout | Snake |
|--------|------|----------|-------|
| **Difficulty** | Easy | Medium | Easy |
| **Lines of Code** | ~520 | ~600 | ~520 |
| **Players** | 1-2 | 1 | 1 |
| **AI** | Yes | No | No |
| **Physics** | Simple | Vector | Grid |
| **Best For** | Multiplayer | Effects | Grids |

## History

Pong was one of the first arcade video games, created by Atari in 1972. It helped establish the video game industry and remains a fundamental example of game design principles.

## Credits

- **Original Game**: Atari's Pong (1972)
- **Implementation**: Playdate Pipeline Example
- **Design**: Classic arcade gameplay

## License

MIT License - Part of the Playdate itch.io Pipeline project.

---

**Game on!** 🏓

For more examples, see [examples/README.md](../README.md).
