--[[
    SNAKE - Classic snake game for Playdate

    Features:
    - Unique crank-based turning mechanic
    - Grid-based movement with smooth animations
    - Progressive difficulty (speed increases)
    - Food spawning and collision
    - Self-collision and wall detection
    - High score tracking
    - Clean retro aesthetic

    Controls:
    - Crank: Turn snake left/right (rotate crank to turn)
    - D-Pad: Alternative direction control
    - A Button: Start game / Restart
    - B Button: Toggle FPS display
]]

-- Import Playdate libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

-- Shortcuts
local gfx <const> = playdate.graphics

-- Screen constants
local SCREEN_WIDTH <const> = 400
local SCREEN_HEIGHT <const> = 240

-- Grid configuration
local GRID_SIZE <const> = 10  -- Each cell is 10x10 pixels
local GRID_WIDTH <const> = SCREEN_WIDTH / GRID_SIZE
local GRID_HEIGHT <const> = SCREEN_HEIGHT / GRID_SIZE

-- Game states
local STATE_MENU <const> = 0
local STATE_PLAYING <const> = 1
local STATE_GAME_OVER <const> = 2

-- Directions
local DIR_UP <const> = 0
local DIR_RIGHT <const> = 1
local DIR_DOWN <const> = 2
local DIR_LEFT <const> = 3

-- Game configuration
local INITIAL_SPEED <const> = 150  -- Milliseconds per move
local SPEED_INCREMENT <const> = 5  -- Speed up every N food
local MAX_SPEED <const> = 50

-- Game state variables
local gameState = STATE_MENU
local score = 0
local highScore = 0

-- Snake data
local snake = {}
local snakeDirection = DIR_RIGHT
local nextDirection = DIR_RIGHT
local snakeLength = 3

-- Food
local food = {x = 0, y = 0}

-- Timing
local moveTimer = nil
local currentSpeed = INITIAL_SPEED

-- Crank state
local lastCrankPosition = 0
local crankTurnThreshold = 30  -- Degrees needed to turn

-- Visual
local animationProgress = 0

--[[
    Grid helper functions
]]
function gridToScreen(gridX, gridY)
    return gridX * GRID_SIZE, gridY * GRID_SIZE
end

function isValidPosition(x, y)
    return x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT
end

--[[
    Initialize snake
]]
function initSnake()
    snake = {}
    local startX = math.floor(GRID_WIDTH / 2)
    local startY = math.floor(GRID_HEIGHT / 2)

    -- Create initial snake (3 segments)
    for i = 0, 2 do
        table.insert(snake, {
            x = startX - i,
            y = startY,
            prevX = startX - i,
            prevY = startY
        })
    end

    snakeDirection = DIR_RIGHT
    nextDirection = DIR_RIGHT
    snakeLength = 3
    currentSpeed = INITIAL_SPEED
    animationProgress = 0

    -- Reset crank position
    lastCrankPosition = playdate.getCrankPosition()
end

--[[
    Direction helpers
]]
function getDirectionVector(dir)
    if dir == DIR_UP then return 0, -1
    elseif dir == DIR_RIGHT then return 1, 0
    elseif dir == DIR_DOWN then return 0, 1
    elseif dir == DIR_LEFT then return -1, 0
    end
    return 0, 0
end

function isOppositeDirection(dir1, dir2)
    return (dir1 + 2) % 4 == dir2
end

function turnLeft(dir)
    return (dir - 1 + 4) % 4
end

function turnRight(dir)
    return (dir + 1) % 4
end

--[[
    Input handling
]]
function handleInput()
    -- Crank turning (primary method)
    local crankPosition = playdate.getCrankPosition()
    local crankChange = crankPosition - lastCrankPosition

    -- Handle wraparound (360 to 0)
    if crankChange > 180 then
        crankChange = crankChange - 360
    elseif crankChange < -180 then
        crankChange = crankChange + 360
    end

    -- Turn based on crank rotation
    if crankChange > crankTurnThreshold then
        -- Cranked clockwise - turn right
        local newDir = turnRight(snakeDirection)
        if not isOppositeDirection(newDir, snakeDirection) then
            nextDirection = newDir
        end
        lastCrankPosition = crankPosition
    elseif crankChange < -crankTurnThreshold then
        -- Cranked counter-clockwise - turn left
        local newDir = turnLeft(snakeDirection)
        if not isOppositeDirection(newDir, snakeDirection) then
            nextDirection = newDir
        end
        lastCrankPosition = crankPosition
    end

    -- D-pad control (alternative)
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        if not isOppositeDirection(DIR_UP, snakeDirection) then
            nextDirection = DIR_UP
        end
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        if not isOppositeDirection(DIR_DOWN, snakeDirection) then
            nextDirection = DIR_DOWN
        end
    elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
        if not isOppositeDirection(DIR_LEFT, snakeDirection) then
            nextDirection = DIR_LEFT
        end
    elseif playdate.buttonJustPressed(playdate.kButtonRight) then
        if not isOppositeDirection(DIR_RIGHT, snakeDirection) then
            nextDirection = DIR_RIGHT
        end
    end
end

--[[
    Food spawning
]]
function spawnFood()
    local maxAttempts = 100
    local attempts = 0

    repeat
        food.x = math.random(0, GRID_WIDTH - 1)
        food.y = math.random(0, GRID_HEIGHT - 1)
        attempts += 1

        -- Check if food is on snake
        local onSnake = false
        for _, segment in ipairs(snake) do
            if segment.x == food.x and segment.y == food.y then
                onSnake = true
                break
            end
        end

        if not onSnake then
            return
        end
    until attempts >= maxAttempts

    -- Fallback: place at 0,0 if we can't find a spot
    food.x = 0
    food.y = 0
end

--[[
    Snake movement
]]
function moveSnake()
    -- Apply queued direction change
    snakeDirection = nextDirection

    -- Get direction vector
    local dx, dy = getDirectionVector(snakeDirection)

    -- Calculate new head position
    local head = snake[1]
    local newX = head.x + dx
    local newY = head.y + dy

    -- Check wall collision
    if not isValidPosition(newX, newY) then
        gameOver()
        return
    end

    -- Check self collision
    for i = 1, #snake do
        if snake[i].x == newX and snake[i].y == newY then
            gameOver()
            return
        end
    end

    -- Store previous positions for animation
    for _, segment in ipairs(snake) do
        segment.prevX = segment.x
        segment.prevY = segment.y
    end

    -- Insert new head
    table.insert(snake, 1, {
        x = newX,
        y = newY,
        prevX = head.x,
        prevY = head.y
    })

    -- Check food collision
    if newX == food.x and newY == food.y then
        score += 10
        snakeLength += 1

        -- Increase speed every 5 food
        if score % 50 == 0 and currentSpeed > MAX_SPEED then
            currentSpeed -= 10
            moveTimer.duration = currentSpeed
        end

        spawnFood()
    else
        -- Remove tail if not growing
        while #snake > snakeLength do
            table.remove(snake)
        end
    end

    -- Reset animation
    animationProgress = 0
end

function gameOver()
    gameState = STATE_GAME_OVER

    if score > highScore then
        highScore = score
        playdate.datastore.write({highScore = highScore}, "snake_save")
    end

    if moveTimer then
        moveTimer:remove()
        moveTimer = nil
    end
end

--[[
    Drawing functions
]]
function drawGrid()
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(1)

    -- Draw vertical lines
    for x = 0, GRID_WIDTH do
        local screenX = x * GRID_SIZE
        gfx.drawLine(screenX, 0, screenX, SCREEN_HEIGHT)
    end

    -- Draw horizontal lines
    for y = 0, GRID_HEIGHT do
        local screenY = y * GRID_SIZE
        gfx.drawLine(0, screenY, SCREEN_WIDTH, screenY)
    end
end

function drawSnake()
    gfx.setColor(gfx.kColorBlack)

    for i, segment in ipairs(snake) do
        -- Interpolate position for smooth animation
        local t = math.min(animationProgress, 1.0)
        local x = segment.prevX + (segment.x - segment.prevX) * t
        local y = segment.prevY + (segment.y - segment.prevY) * t

        local screenX, screenY = gridToScreen(x, y)

        -- Draw segment
        if i == 1 then
            -- Head - slightly different
            gfx.fillRect(screenX + 1, screenY + 1, GRID_SIZE - 2, GRID_SIZE - 2)

            -- Draw eyes based on direction
            gfx.setColor(gfx.kColorWhite)
            if snakeDirection == DIR_UP then
                gfx.fillRect(screenX + 2, screenY + 2, 2, 2)
                gfx.fillRect(screenX + 6, screenY + 2, 2, 2)
            elseif snakeDirection == DIR_RIGHT then
                gfx.fillRect(screenX + 6, screenY + 2, 2, 2)
                gfx.fillRect(screenX + 6, screenY + 6, 2, 2)
            elseif snakeDirection == DIR_DOWN then
                gfx.fillRect(screenX + 2, screenY + 6, 2, 2)
                gfx.fillRect(screenX + 6, screenY + 6, 2, 2)
            elseif snakeDirection == DIR_LEFT then
                gfx.fillRect(screenX + 2, screenY + 2, 2, 2)
                gfx.fillRect(screenX + 2, screenY + 6, 2, 2)
            end
            gfx.setColor(gfx.kColorBlack)
        else
            -- Body
            gfx.fillRect(screenX + 1, screenY + 1, GRID_SIZE - 2, GRID_SIZE - 2)
        end
    end
end

function drawFood()
    gfx.setColor(gfx.kColorBlack)
    local screenX, screenY = gridToScreen(food.x, food.y)

    -- Draw food as a circle
    gfx.fillCircleAtPoint(
        screenX + GRID_SIZE / 2,
        screenY + GRID_SIZE / 2,
        GRID_SIZE / 2 - 2
    )

    -- Add a highlight
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(
        screenX + GRID_SIZE / 2 - 1,
        screenY + GRID_SIZE / 2 - 1,
        1
    )
end

function drawUI()
    gfx.setColor(gfx.kColorBlack)

    -- Score (top left)
    gfx.drawText("Score: " .. score, 5, 5)

    -- Length (top center)
    local lengthText = "Length: " .. snakeLength
    local lengthWidth = gfx.getTextSize(lengthText)
    gfx.drawText(lengthText, (SCREEN_WIDTH - lengthWidth) / 2, 5)

    -- Speed indicator (top right)
    local speedPercent = math.floor((1 - (currentSpeed - MAX_SPEED) / (INITIAL_SPEED - MAX_SPEED)) * 100)
    local speedText = "Speed: " .. speedPercent .. "%"
    local speedWidth = gfx.getTextSize(speedText)
    gfx.drawText(speedText, SCREEN_WIDTH - speedWidth - 5, 5)
end

function drawMenu()
    gfx.clear()
    gfx.setColor(gfx.kColorBlack)

    -- Title
    local title = "SNAKE"
    local titleWidth = gfx.getTextSize(title)
    gfx.drawText(title, (SCREEN_WIDTH - titleWidth) / 2, 60)

    -- Instructions
    local instructions = {
        "Crank: Turn snake",
        "D-Pad: Alternative control",
        "",
        "Eat food to grow!",
        "Don't hit walls or yourself!",
        "",
        "Press A to Start"
    }

    local y = 100
    for _, line in ipairs(instructions) do
        local width = gfx.getTextSize(line)
        gfx.drawText(line, (SCREEN_WIDTH - width) / 2, y)
        y += 15
    end

    -- High score
    if highScore > 0 then
        local scoreText = "High Score: " .. highScore
        local scoreWidth = gfx.getTextSize(scoreText)
        gfx.drawText(scoreText, (SCREEN_WIDTH - scoreWidth) / 2, 210)
    end
end

function drawGameOver()
    gfx.clear()
    gfx.setColor(gfx.kColorBlack)

    -- Game Over text
    local gameOverText = "GAME OVER"
    local textWidth = gfx.getTextSize(gameOverText)
    gfx.drawText(gameOverText, (SCREEN_WIDTH - textWidth) / 2, 80)

    -- Final score
    local scoreText = "Score: " .. score
    local scoreWidth = gfx.getTextSize(scoreText)
    gfx.drawText(scoreText, (SCREEN_WIDTH - scoreWidth) / 2, 110)

    -- Length
    local lengthText = "Length: " .. snakeLength
    local lengthWidth = gfx.getTextSize(lengthText)
    gfx.drawText(lengthText, (SCREEN_WIDTH - lengthWidth) / 2, 130)

    -- High score
    if score > highScore then
        local newHighText = "NEW HIGH SCORE!"
        local newHighWidth = gfx.getTextSize(newHighText)
        gfx.drawText(newHighText, (SCREEN_WIDTH - newHighWidth) / 2, 160)
    else
        local highScoreText = "High Score: " .. highScore
        local highScoreWidth = gfx.getTextSize(highScoreText)
        gfx.drawText(highScoreText, (SCREEN_WIDTH - highScoreWidth) / 2, 160)
    end

    -- Restart prompt
    local restartText = "Press A to Restart"
    local restartWidth = gfx.getTextSize(restartText)
    gfx.drawText(restartText, (SCREEN_WIDTH - restartWidth) / 2, 200)
end

--[[
    Game state functions
]]
function startNewGame()
    score = 0
    initSnake()
    spawnFood()

    -- Create move timer
    if moveTimer then
        moveTimer:remove()
    end

    moveTimer = playdate.timer.new(currentSpeed, function()
        moveSnake()
    end)
    moveTimer.repeats = true

    gameState = STATE_PLAYING
end

--[[
    Main game loop
]]
function playdate.update()
    if gameState == STATE_MENU then
        drawMenu()

        if playdate.buttonJustPressed(playdate.kButtonA) then
            startNewGame()
        end

    elseif gameState == STATE_PLAYING then
        -- Update animation
        animationProgress += 0.15

        -- Handle input
        handleInput()

        -- Draw
        gfx.clear()
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

        drawGrid()
        drawFood()
        drawSnake()
        drawUI()

        -- Update timers
        playdate.timer.updateTimers()

    elseif gameState == STATE_GAME_OVER then
        drawGameOver()

        if playdate.buttonJustPressed(playdate.kButtonA) then
            gameState = STATE_MENU
        end
    end

    -- B button toggles FPS (all states)
    if playdate.buttonJustPressed(playdate.kButtonB) then
        local showFPS = not playdate.isFPSDisplayVisible()
        playdate.setShowFPS(showFPS)
    end
end

--[[
    Lifecycle callbacks
]]
function playdate.deviceWillLock()
    playdate.datastore.write({highScore = highScore}, "snake_save")
end

function playdate.gameWillTerminate()
    playdate.datastore.write({highScore = highScore}, "snake_save")
end

--[[
    Initialize game
]]
function init()
    -- Load high score
    local saveData = playdate.datastore.read("snake_save")
    if saveData and saveData.highScore then
        highScore = saveData.highScore
    end

    -- Seed random
    math.randomseed(playdate.getSecondsSinceEpoch())

    -- Initialize crank position
    lastCrankPosition = playdate.getCrankPosition()

    print("Snake initialized!")
    print("Crank to turn, A to start")
end

-- Start the game
init()
