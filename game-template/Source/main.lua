--[[
    Playdate Game Template
    Main entry point for your Playdate game

    This template provides:
    - Basic game loop
    - Input handling (buttons, d-pad, crank)
    - Sprite management
    - Simple player movement
    - FPS display
]]

-- Import Playdate libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

-- Shortcuts for commonly used modules
local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

-- Game constants
local SCREEN_WIDTH <const> = 400
local SCREEN_HEIGHT <const> = 240

-- Game state
local player = nil
local score = 0
local gameStarted = false
local showFPS = true

-- Fonts
local gameFont = nil

--[[
    Initialize the game
    Called once when the game starts
]]
function init()
    -- Set up fonts
    gameFont = gfx.font.new('fonts/Asheville-Sans-14-Bold')
    gfx.setFont(gameFont)

    -- Create player
    player = {
        sprite = gfx.sprite.new(),
        x = SCREEN_WIDTH / 2,
        y = SCREEN_HEIGHT / 2,
        speed = 3,
        crankSensitivity = 5
    }

    -- Create a simple player graphic (white square for now)
    local playerImage = gfx.image.new(20, 20)
    gfx.pushContext(playerImage)
        gfx.fillRect(0, 0, 20, 20)
    gfx.popContext()

    player.sprite:setImage(playerImage)
    player.sprite:moveTo(player.x, player.y)
    player.sprite:setZIndex(100)
    player.sprite:add()

    -- Initialize game state
    score = 0
    gameStarted = true

    print("Game initialized!")
end

--[[
    Handle player input
    Updates player position based on button presses and crank
]]
function handleInput()
    -- D-pad movement
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        player.y = math.max(10, player.y - player.speed)
    end
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        player.y = math.min(SCREEN_HEIGHT - 10, player.y + player.speed)
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        player.x = math.max(10, player.x - player.speed)
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        player.x = math.min(SCREEN_WIDTH - 10, player.x + player.speed)
    end

    -- Crank input (controls horizontal movement)
    local crankChange = playdate.getCrankChange()
    if crankChange ~= 0 then
        player.x = player.x + (crankChange / player.crankSensitivity)
        player.x = math.max(10, math.min(SCREEN_WIDTH - 10, player.x))
    end

    -- A button action
    if playdate.buttonJustPressed(playdate.kButtonA) then
        score = score + 1
        print("Score: " .. score)
    end

    -- B button action
    if playdate.buttonJustPressed(playdate.kButtonB) then
        -- Toggle FPS display
        showFPS = not showFPS
        playdate.setFPSVisible(showFPS)
    end

    -- Update player sprite position
    player.sprite:moveTo(player.x, player.y)
end

--[[
    Draw the game
    Called every frame to render the game
]]
function drawGame()
    -- Clear screen
    gfx.clear()

    -- Draw background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    -- Draw a grid pattern
    gfx.setColor(gfx.kColorBlack)
    for x = 0, SCREEN_WIDTH, 40 do
        gfx.drawLine(x, 0, x, SCREEN_HEIGHT)
    end
    for y = 0, SCREEN_HEIGHT, 40 do
        gfx.drawLine(0, y, SCREEN_WIDTH, y)
    end

    -- Draw sprites (includes player)
    gfx.sprite.update()

    -- Draw UI
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    -- Score
    gfx.drawText("Score: " .. score, 10, 10)

    -- Instructions
    gfx.drawText("D-Pad/Crank: Move | A: +Score | B: Toggle FPS", 10, 220)

    -- Crank indicator
    local crankPosition = playdate.getCrankPosition()
    local crankText = string.format("Crank: %.0f°", crankPosition)
    gfx.drawText(crankText, SCREEN_WIDTH - 100, 10)
end

--[[
    Main game loop
    Called every frame (~30 FPS)
]]
function playdate.update()
    if not gameStarted then
        init()
    end

    -- Handle input
    handleInput()

    -- Update game logic here
    -- (Add your game logic, physics, AI, etc.)

    -- Draw everything
    drawGame()

    -- Update timers (if you use them)
    playdate.timer.updateTimers()
end

--[[
    Called when the game is about to be suspended
    (Playdate lock button pressed)
]]
function playdate.gameWillPause()
    -- Save game state here
    print("Game pausing...")
end

--[[
    Called when the game is resumed
]]
function playdate.gameWillResume()
    -- Restore game state here
    print("Game resuming...")
end

--[[
    Called when the game is about to terminate
]]
function playdate.gameWillTerminate()
    -- Final save here
    print("Game terminating...")
end

-- Initialize the game
init()
