# Development Guide

Complete guide for developing Playdate games using this pipeline.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Playdate Lua API Basics](#playdate-lua-api-basics)
- [Project Structure](#project-structure)
- [Best Practices](#best-practices)
- [Testing](#testing)
- [Debugging](#debugging)
- [Performance Optimization](#performance-optimization)
- [Common Patterns](#common-patterns)

## Getting Started

### Prerequisites

1. **Playdate SDK** - Download from [play.date/dev](https://play.date/dev/)
2. **Git** - For version control
3. **Text Editor** - VS Code, Sublime Text, or your preferred editor
4. **Terminal** - For running build scripts

### Initial Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd playdate-itch-pipeline

# Set up Playdate SDK path
export PLAYDATE_SDK_PATH="/path/to/PlaydateSDK"

# Create your first game
./scripts/create-game.sh "My Awesome Game" "Your Name"
```

## Development Workflow

### 1. Create a New Game

```bash
./scripts/create-game.sh "Game Name" "Author Name"
```

This creates a new directory with:
- `Source/main.lua` - Main game logic
- `Source/pdxinfo` - Game metadata

### 2. Code Your Game

Edit `Source/main.lua` with your game logic:

```lua
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx = playdate.graphics

-- Initialize
function init()
    -- Your initialization code
end

-- Main game loop
function playdate.update()
    -- Your game logic
    gfx.sprite.update()
    playdate.timer.updateTimers()
end

init()
```

### 3. Build and Test

```bash
# Build for simulator
./scripts/build.sh --source your-game-name

# Run in simulator
./scripts/run-simulator.sh

# Validate your code
./scripts/validate.sh --source your-game-name
```

### 4. Iterate

1. Make changes to your code
2. Build
3. Test in simulator
4. Repeat

## Playdate Lua API Basics

### Graphics

```lua
import "CoreLibs/graphics"
local gfx = playdate.graphics

-- Drawing
gfx.drawText("Hello!", 10, 10)
gfx.drawRect(50, 50, 100, 100)
gfx.fillRect(50, 50, 100, 100)
gfx.drawCircleAtPoint(200, 120, 30)

-- Images
local image = gfx.image.new("images/sprite")
image:draw(0, 0)

-- Sprites
local sprite = gfx.sprite.new()
sprite:setImage(image)
sprite:moveTo(200, 120)
sprite:add()
```

### Input

```lua
-- D-pad
if playdate.buttonIsPressed(playdate.kButtonUp) then
    -- Move up
end

if playdate.buttonJustPressed(playdate.kButtonA) then
    -- A button was just pressed
end

-- Crank
local crankChange = playdate.getCrankChange()
if crankChange ~= 0 then
    -- Crank was turned
end

-- Check if crank is docked
if playdate.isCrankDocked() then
    -- Crank is put away
end
```

### Sound

```lua
import "CoreLibs/sound"

-- Play a sound
local sound = playdate.sound.sampleplayer.new("sounds/beep")
sound:play()

-- Music
local music = playdate.sound.fileplayer.new("music/track")
music:play()
```

### Timers

```lua
import "CoreLibs/timer"

-- Create a timer
playdate.timer.new(1000, function()
    print("1 second elapsed!")
end)

-- Repeating timer
playdate.timer.new(500, function()
    -- Runs every 500ms
end):repeats()

-- Update timers (in playdate.update())
playdate.timer.updateTimers()
```

### Animation

```lua
import "CoreLibs/animation"

-- Animator for smooth movement
local animator = playdate.graphics.animator.new(
    1000,  -- duration (ms)
    0,     -- start value
    100    -- end value
)

function playdate.update()
    local value = animator:currentValue()
    -- Use value for position, etc.
end
```

## Project Structure

### Recommended Layout

```
your-game/
├── Source/
│   ├── main.lua              # Entry point
│   ├── pdxinfo               # Game metadata
│   ├── game/                 # Game logic
│   │   ├── player.lua
│   │   ├── enemy.lua
│   │   └── level.lua
│   ├── utils/                # Utilities
│   │   ├── collision.lua
│   │   └── math.lua
│   ├── images/               # Image assets
│   │   ├── player.png
│   │   └── background.png
│   ├── sounds/               # Sound effects
│   │   └── jump.wav
│   ├── music/                # Music files
│   │   └── theme.mp3
│   └── fonts/                # Custom fonts
│       └── game-font.fnt
```

### Organizing Code

**main.lua** - Keep it clean:

```lua
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

-- Import your game modules
import "game/player"
import "game/enemy"
import "game/level"

local gfx = playdate.graphics

-- Game state
local gameState = "menu"
local level = nil
local player = nil

function init()
    level = Level()
    player = Player(200, 120)
end

function playdate.update()
    if gameState == "playing" then
        player:update()
        level:update()
    end

    gfx.sprite.update()
end

init()
```

**Separate modules** (e.g., game/player.lua):

```lua
class('Player').extends()

function Player:init(x, y)
    Player.super.init(self)

    self.x = x
    self.y = y
    self.speed = 3

    -- Create sprite
    self.sprite = gfx.sprite.new()
    self.sprite:moveTo(x, y)
    self.sprite:add()
end

function Player:update()
    -- Handle input
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.x += self.speed
    end

    self.sprite:moveTo(self.x, self.y)
end
```

## Best Practices

### 1. Performance

```lua
-- ✓ GOOD: Cache commonly used values
local gfx = playdate.graphics
local kButtonA = playdate.kButtonA

function playdate.update()
    if playdate.buttonIsPressed(kButtonA) then
        gfx.drawText("Pressed", 10, 10)
    end
end

-- ✗ BAD: Repeated lookups
function playdate.update()
    if playdate.buttonIsPressed(playdate.kButtonA) then
        playdate.graphics.drawText("Pressed", 10, 10)
    end
end
```

### 2. Memory Management

```lua
-- Clean up sprites when done
function Enemy:destroy()
    self.sprite:remove()
    self.sprite = nil
end

-- Remove timers
function cleanup()
    playdate.timer.allTimers().each(function(timer)
        timer:remove()
    end)
end
```

### 3. Screen Dimensions

```lua
-- Use constants for screen size
local SCREEN_WIDTH = 400
local SCREEN_HEIGHT = 240

-- Keep objects in bounds
if player.x > SCREEN_WIDTH then
    player.x = SCREEN_WIDTH
end
```

### 4. Save Data

```lua
-- Save game state
function saveGame()
    local data = {
        level = currentLevel,
        score = score
    }
    playdate.datastore.write(data, "savegame")
end

-- Load game state
function loadGame()
    local data = playdate.datastore.read("savegame")
    if data then
        currentLevel = data.level
        score = data.score
    end
end
```

### 5. Error Handling

```lua
-- Safe file loading
local image = gfx.image.new("images/sprite")
if image == nil then
    print("Error: Could not load sprite image")
    -- Provide fallback
    image = gfx.image.new(32, 32)
end
```

## Testing

### Manual Testing Checklist

- [ ] Game starts without errors
- [ ] All controls work correctly
- [ ] Graphics render properly
- [ ] Sounds play correctly
- [ ] Game performs well (30 FPS minimum)
- [ ] Save/load works
- [ ] Crank interaction (if used)
- [ ] System menu integration

### Validation Script

```bash
# Run comprehensive validation
./scripts/validate.sh --source your-game

# Strict mode (warnings as errors)
./scripts/validate.sh --source your-game --strict
```

### Performance Testing

```lua
-- Enable FPS display
playdate.setShowFPS(true)

-- Measure execution time
local start = playdate.getCurrentTimeMilliseconds()
-- Your code here
local elapsed = playdate.getCurrentTimeMilliseconds() - start
print("Execution time: " .. elapsed .. "ms")
```

## Debugging

### Console Output

```lua
-- Print to console
print("Debug message")
print("Variable value:", myVariable)

-- Formatted output
printTable(myTable)  -- Shows table contents
```

### Debug Drawing

```lua
-- Draw debug info
function drawDebug()
    playdate.graphics.drawText(
        "FPS: " .. playdate.getFPS(),
        10, 10
    )
    playdate.graphics.drawText(
        "Sprites: " .. #gfx.sprite.getAllSprites(),
        10, 30
    )
end

function playdate.update()
    -- Your game logic

    if DEBUG_MODE then
        drawDebug()
    end
end
```

### Common Issues

**Game runs slow:**
- Too many sprites? Reduce or pool them
- Heavy calculations? Cache results
- Large images? Optimize size/format

**Images not appearing:**
- Check file paths (case-sensitive!)
- Verify image format (PNG, 1-bit)
- Check images are in Source/images/

**Sounds not playing:**
- Verify sound format (WAV, AIFF)
- Check file paths
- Ensure sounds are in Source/sounds/

## Performance Optimization

### Sprite Management

```lua
-- Use sprite pools for frequently created/destroyed objects
local bulletPool = {}

function getBullet()
    local bullet = table.remove(bulletPool)
    if bullet == nil then
        bullet = Bullet()
    end
    return bullet
end

function returnBullet(bullet)
    bullet.sprite:moveTo(-100, -100)  -- Move offscreen
    bullet.sprite:setVisible(false)
    table.insert(bulletPool, bullet)
end
```

### Dirty Rect Drawing

```lua
-- Only redraw changed areas
function playdate.update()
    -- Update sprites (uses dirty rects automatically)
    gfx.sprite.update()

    -- For manual drawing
    if needsRedraw then
        gfx.setClipRect(x, y, width, height)
        -- Draw only in clip rect
        gfx.clearClipRect()
    end
end
```

### Reduce Garbage Collection

```lua
-- ✓ GOOD: Reuse tables
local tempTable = {}

function doSomething()
    -- Clear and reuse
    tempTable = {}
    -- Use tempTable
end

-- ✗ BAD: Create new tables constantly
function doSomething()
    local newTable = {}  -- Creates garbage
    -- Use newTable
end
```

## Common Patterns

### State Machine

```lua
local states = {
    menu = {
        enter = function()
            -- Setup menu
        end,
        update = function()
            -- Menu logic
        end,
        exit = function()
            -- Cleanup
        end
    },
    playing = {
        enter = function()
            -- Start game
        end,
        update = function()
            -- Game logic
        end,
        exit = function()
            -- Pause/cleanup
        end
    }
}

local currentState = "menu"

function setState(newState)
    states[currentState].exit()
    currentState = newState
    states[currentState].enter()
end

function playdate.update()
    states[currentState].update()
end
```

### Object Pooling

```lua
local Pool = {}

function Pool:new(createFn, maxSize)
    local pool = {
        objects = {},
        createFn = createFn,
        maxSize = maxSize or 100
    }
    setmetatable(pool, { __index = Pool })
    return pool
end

function Pool:acquire()
    local obj = table.remove(self.objects)
    if obj == nil then
        obj = self.createFn()
    end
    return obj
end

function Pool:release(obj)
    if #self.objects < self.maxSize then
        table.insert(self.objects, obj)
    end
end

-- Usage
local bulletPool = Pool:new(function()
    return Bullet()
end, 50)
```

### Scene Management

```lua
class('Scene').extends()

function Scene:init()
    self.sprites = {}
end

function Scene:add(sprite)
    table.insert(self.sprites, sprite)
    sprite:add()
end

function Scene:cleanup()
    for _, sprite in ipairs(self.sprites) do
        sprite:remove()
    end
    self.sprites = {}
end

-- Usage
local currentScene = nil

function loadScene(newScene)
    if currentScene then
        currentScene:cleanup()
    end
    currentScene = newScene
end
```

## Resources

### Official Documentation

- [Playdate SDK Documentation](https://sdk.play.date/)
- [Playdate Lua API Reference](https://sdk.play.date/inside-playdate/)
- [Playdate Developer Forum](https://devforum.play.date/)

### Community

- [r/PlaydateConsole](https://reddit.com/r/PlaydateConsole)
- [Playdate Squad Discord](https://discord.gg/playdate)

### Tools

- [Playdate Simulator](https://play.date/dev/) - Test your games
- [pdutil](https://sdk.play.date/inside-playdate/#pdutil) - Command-line utilities
- [VS Code Playdate Extension](https://marketplace.visualstudio.com/items?itemName=Didier.playdate) - IDE support

## Next Steps

1. Read the [Deployment Guide](DEPLOYMENT.md)
2. Check out example games in the repository
3. Join the Playdate developer community
4. Start building your game!

---

Happy coding! 🎮✨
