# Space Invaders

Classic arcade wave-based shooter reimagined for Playdate with crank controls.

## Features

- **Classic Gameplay**: Faithful recreation of the arcade classic
- **Crank Controls**: Smooth horizontal movement with the crank
- **Three Alien Types**: Octopus (30pts), Crab (20pts), Squid (10pts)
- **Destructible Shields**: Pixel-based destruction system
- **Mystery UFO**: Random bonus ship worth 100-200 points
- **Wave Progression**: Increasing difficulty with each wave
- **High Score Tracking**: Persistent high score with data saving

## Controls

| Input | Action |
|-------|--------|
| Crank | Move ship left/right (smooth) |
| D-Pad Left/Right | Alternative movement |
| A Button | Fire |

## Game Mechanics

### Alien Formation
- 5 rows x 11 columns of aliens
- Different point values per row:
  - Top row (Octopus): 30 points
  - Middle rows (Crab): 20 points
  - Bottom rows (Squid): 10 points

### Alien Movement
- Aliens move side-to-side across the screen
- Drop down when reaching screen edges
- Speed increases as aliens are destroyed
- Each wave starts faster than the last

### Shields
- 4 destructible shields protect the player
- Bullets from both sides damage shields
- Shields use pixel-based destruction for realistic damage
- Classic arch shape with bottom notch

### UFO Bonus
- Mystery ship appears periodically at top
- Worth 100, 150, or 200 points randomly
- Triggers screen flash when destroyed

### Wave Completion
- Clear all aliens to advance to next wave
- Bonus points: Wave number x 100
- New formation spawns faster each wave

## Technical Highlights

### Pixel-Based Shield Destruction
```lua
-- Each shield has a pixel grid
shield.pixels[py][px] = true/false

-- Damage creates circular holes
local function damageShield(shield, hitX, hitY, radius)
    for py, px in area do
        local dist = math.sqrt((px - localX)^2 + (py - localY)^2)
        if dist <= radius then
            shield.pixels[py][px] = false
        end
    end
end
```

### Adaptive Difficulty
```lua
-- Speed increases as fewer aliens remain
local aliveCount = countAliveAliens()
alienMoveDelay = math.max(2, math.floor(60 * aliveCount / totalAliens) - waveBonus)
```

### Column-Based Alien Shooting
Only the bottom-most alien in each column can shoot, mimicking the original game's behavior.

### Zigzag Alien Bullets
```lua
-- Animated zigzag pattern
local offset = math.sin(bullet.y * 0.3) * 2
gfx.fillRect(bullet.x + offset, bullet.y - 2, 2, 4)
gfx.fillRect(bullet.x - offset, bullet.y + 2, 2, 4)
```

## Building

```bash
# From project root
make build GAME_SOURCE=examples/space-invaders

# Run in simulator
make run
```

## Project Structure

```
space-invaders/
├── Source/
│   ├── main.lua    # Game code (~700 lines)
│   └── pdxinfo     # Game metadata
└── README.md       # This file
```

## Difficulty Progression

| Wave | Base Move Delay | Alien Shot Chance |
|------|-----------------|-------------------|
| 1 | 60 frames | 2.5% per frame |
| 2 | 55 frames | 3.0% per frame |
| 3 | 50 frames | 3.5% per frame |
| 5 | 40 frames | 4.5% per frame |
| 10 | 15 frames | 7.0% per frame |

## Score System

| Target | Points |
|--------|--------|
| Squid (bottom rows) | 10 |
| Crab (middle rows) | 20 |
| Octopus (top row) | 30 |
| Mystery UFO | 100/150/200 |
| Wave Clear Bonus | Wave x 100 |

## Tips for High Scores

1. **Prioritize top aliens**: They're worth more points
2. **Save shields**: Don't shoot through them unnecessarily
3. **Target UFOs**: High risk, high reward
4. **Thin the edges**: Reduces formation width and movement
5. **Stay mobile**: Use the crank for quick dodging

## Credits

Inspired by the 1978 Taito arcade classic by Tomohiro Nishikado.

## License

MIT License - See main project LICENSE file.
