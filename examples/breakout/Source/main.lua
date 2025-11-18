--[[
    BREAKOUT - Classic brick-breaking game for Playdate

    Features:
    - Crank-controlled paddle with smooth analog movement
    - Multiple brick types with different hit points
    - Particle effects and screen shake
    - Progressive difficulty
    - High score tracking
    - State management (menu, playing, game over)

    Controls:
    - Crank: Move paddle left/right
    - A Button: Launch ball / Start game / Restart
    - B Button: Toggle FPS display
]]

-- Import Playdate libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Shortcuts
local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

-- Screen constants
local SCREEN_WIDTH <const> = 400
local SCREEN_HEIGHT <const> = 240

-- Game states
local STATE_MENU <const> = 0
local STATE_PLAYING <const> = 1
local STATE_GAME_OVER <const> = 2

-- Game configuration
local PADDLE_WIDTH <const> = 60
local PADDLE_HEIGHT <const> = 8
local PADDLE_Y <const> = 220
local PADDLE_SPEED <const> = 8

local BALL_SIZE <const> = 6
local BALL_SPEED_INITIAL <const> = 3
local BALL_SPEED_MAX <const> = 7

local BRICK_WIDTH <const> = 38
local BRICK_HEIGHT <const> = 12
local BRICK_ROWS <const> = 5
local BRICK_COLS <const> = 10
local BRICK_OFFSET_X <const> = 5
local BRICK_OFFSET_Y <const> = 40

-- Game state variables
local gameState = STATE_MENU
local score = 0
local highScore = 0
local lives = 3
local level = 1

-- Game objects
local paddle = nil
local ball = nil
local bricks = {}
local particles = {}

-- Visual effects
local screenShake = 0
local screenShakeIntensity = 0

-- Timing
local ballLaunched = false
local gameOverTimer = 0

--[[
    Particle system for visual effects
]]
function createParticle(x, y, vx, vy)
    return {
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        life = 1.0,
        decay = 0.05
    }
end

function updateParticles()
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x += p.vx
        p.y += p.vy
        p.vy += 0.2  -- Gravity
        p.life -= p.decay

        if p.life <= 0 then
            table.remove(particles, i)
        end
    end
end

function drawParticles()
    for _, p in ipairs(particles) do
        local size = math.floor(p.life * 4)
        if size > 0 then
            gfx.fillRect(p.x - size/2, p.y - size/2, size, size)
        end
    end
end

function spawnParticles(x, y, count)
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local speed = 2 + math.random() * 2
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        table.insert(particles, createParticle(x, y, vx, vy))
    end
end

--[[
    Screen shake effect
]]
function addScreenShake(intensity)
    screenShake = intensity
    screenShakeIntensity = intensity
end

function updateScreenShake()
    if screenShake > 0 then
        screenShake *= 0.8
        if screenShake < 0.5 then
            screenShake = 0
        end
    end
end

function getScreenShakeOffset()
    if screenShake > 0 then
        local offsetX = (math.random() - 0.5) * screenShake
        local offsetY = (math.random() - 0.5) * screenShake
        return offsetX, offsetY
    end
    return 0, 0
end

--[[
    Initialize paddle
]]
function initPaddle()
    paddle = {
        x = SCREEN_WIDTH / 2,
        y = PADDLE_Y,
        width = PADDLE_WIDTH,
        height = PADDLE_HEIGHT,
        targetX = SCREEN_WIDTH / 2
    }
end

function updatePaddle()
    -- Crank control (primary method)
    local crankChange = playdate.getCrankChange()
    if crankChange ~= 0 then
        paddle.targetX += crankChange * 2
    end

    -- D-pad control (alternative)
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        paddle.targetX -= PADDLE_SPEED
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        paddle.targetX += PADDLE_SPEED
    end

    -- Clamp to screen bounds
    paddle.targetX = math.max(paddle.width / 2, math.min(SCREEN_WIDTH - paddle.width / 2, paddle.targetX))

    -- Smooth movement
    paddle.x += (paddle.targetX - paddle.x) * 0.3
end

function drawPaddle()
    gfx.fillRect(
        paddle.x - paddle.width / 2,
        paddle.y - paddle.height / 2,
        paddle.width,
        paddle.height
    )
end

--[[
    Initialize ball
]]
function initBall()
    ball = {
        x = paddle.x,
        y = paddle.y - paddle.height / 2 - BALL_SIZE,
        vx = 0,
        vy = 0,
        speed = BALL_SPEED_INITIAL,
        stuck = true
    }
    ballLaunched = false
end

function launchBall()
    if ball.stuck then
        local angle = -math.pi / 2 + (math.random() - 0.5) * 0.5
        ball.vx = math.cos(angle) * ball.speed
        ball.vy = math.sin(angle) * ball.speed
        ball.stuck = false
        ballLaunched = true
    end
end

function updateBall()
    if ball.stuck then
        -- Follow paddle before launch
        ball.x = paddle.x
        ball.y = paddle.y - paddle.height / 2 - BALL_SIZE

        -- Launch with A button
        if playdate.buttonJustPressed(playdate.kButtonA) then
            launchBall()
        end
    else
        -- Move ball
        ball.x += ball.vx
        ball.y += ball.vy

        -- Wall collisions
        if ball.x - BALL_SIZE / 2 < 0 or ball.x + BALL_SIZE / 2 > SCREEN_WIDTH then
            ball.vx = -ball.vx
            ball.x = math.max(BALL_SIZE / 2, math.min(SCREEN_WIDTH - BALL_SIZE / 2, ball.x))
            addScreenShake(2)
        end

        if ball.y - BALL_SIZE / 2 < 0 then
            ball.vy = -ball.vy
            ball.y = BALL_SIZE / 2
            addScreenShake(2)
        end

        -- Paddle collision
        if ball.y + BALL_SIZE / 2 >= paddle.y - paddle.height / 2 and
           ball.y + BALL_SIZE / 2 <= paddle.y + paddle.height / 2 and
           ball.x >= paddle.x - paddle.width / 2 and
           ball.x <= paddle.x + paddle.width / 2 then

            -- Bounce ball
            ball.vy = -math.abs(ball.vy)

            -- Add spin based on where ball hits paddle
            local hitPos = (ball.x - paddle.x) / (paddle.width / 2)
            ball.vx = hitPos * 3

            -- Increase speed slightly
            ball.speed = math.min(BALL_SPEED_MAX, ball.speed + 0.1)
            local currentSpeed = math.sqrt(ball.vx * ball.vx + ball.vy * ball.vy)
            ball.vx = (ball.vx / currentSpeed) * ball.speed
            ball.vy = (ball.vy / currentSpeed) * ball.speed

            addScreenShake(3)
            spawnParticles(ball.x, ball.y, 5)
        end

        -- Bottom of screen (lose life)
        if ball.y - BALL_SIZE / 2 > SCREEN_HEIGHT then
            lives -= 1
            addScreenShake(8)

            if lives <= 0 then
                gameState = STATE_GAME_OVER
                gameOverTimer = 120  -- 4 seconds at 30fps
            else
                initBall()
            end
        end

        -- Brick collisions
        checkBrickCollisions()
    end
end

function drawBall()
    gfx.fillCircleAtPoint(ball.x, ball.y, BALL_SIZE / 2)
end

--[[
    Initialize bricks
]]
function initBricks()
    bricks = {}

    for row = 0, BRICK_ROWS - 1 do
        for col = 0, BRICK_COLS - 1 do
            local brick = {
                x = BRICK_OFFSET_X + col * (BRICK_WIDTH + 2),
                y = BRICK_OFFSET_Y + row * (BRICK_HEIGHT + 2),
                width = BRICK_WIDTH,
                height = BRICK_HEIGHT,
                hits = 1 + math.floor(row / 2),  -- More hits for higher rows
                maxHits = 1 + math.floor(row / 2),
                active = true
            }
            table.insert(bricks, brick)
        end
    end
end

function checkBrickCollisions()
    for _, brick in ipairs(bricks) do
        if brick.active then
            -- Check collision
            if ball.x + BALL_SIZE / 2 >= brick.x and
               ball.x - BALL_SIZE / 2 <= brick.x + brick.width and
               ball.y + BALL_SIZE / 2 >= brick.y and
               ball.y - BALL_SIZE / 2 <= brick.y + brick.height then

                -- Determine collision side
                local overlapLeft = (ball.x + BALL_SIZE / 2) - brick.x
                local overlapRight = (brick.x + brick.width) - (ball.x - BALL_SIZE / 2)
                local overlapTop = (ball.y + BALL_SIZE / 2) - brick.y
                local overlapBottom = (brick.y + brick.height) - (ball.y - BALL_SIZE / 2)

                local minOverlap = math.min(overlapLeft, overlapRight, overlapTop, overlapBottom)

                if minOverlap == overlapLeft or minOverlap == overlapRight then
                    ball.vx = -ball.vx
                else
                    ball.vy = -ball.vy
                end

                -- Damage brick
                brick.hits -= 1
                if brick.hits <= 0 then
                    brick.active = false
                    score += 10 * brick.maxHits
                    spawnParticles(brick.x + brick.width / 2, brick.y + brick.height / 2, 8)
                    addScreenShake(4)
                else
                    score += 5
                    spawnParticles(brick.x + brick.width / 2, brick.y + brick.height / 2, 3)
                    addScreenShake(2)
                end

                -- Check for level complete
                checkLevelComplete()

                break
            end
        end
    end
end

function checkLevelComplete()
    local allBroken = true
    for _, brick in ipairs(bricks) do
        if brick.active then
            allBroken = false
            break
        end
    end

    if allBroken then
        level += 1
        initBricks()
        initBall()
        ball.speed = math.min(BALL_SPEED_MAX, BALL_SPEED_INITIAL + (level - 1) * 0.5)
    end
end

function drawBricks()
    for _, brick in ipairs(bricks) do
        if brick.active then
            -- Draw brick with different patterns based on hits remaining
            if brick.hits == brick.maxHits then
                gfx.fillRect(brick.x, brick.y, brick.width, brick.height)
            elseif brick.hits == brick.maxHits - 1 then
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer8x8)
                gfx.fillRect(brick.x, brick.y, brick.width, brick.height)
                gfx.setColor(gfx.kColorBlack)
            else
                gfx.drawRect(brick.x, brick.y, brick.width, brick.height)
            end

            -- Draw border
            gfx.drawRect(brick.x, brick.y, brick.width, brick.height)
        end
    end
end

--[[
    Game state functions
]]
function startNewGame()
    score = 0
    lives = 3
    level = 1
    initPaddle()
    initBall()
    initBricks()
    gameState = STATE_PLAYING
end

function drawMenu()
    gfx.clear()

    -- Title
    local title = "BREAKOUT"
    local titleWidth = gfx.getTextSize(title)
    gfx.drawText(title, (SCREEN_WIDTH - titleWidth) / 2, 60)

    -- Instructions
    local instructions = {
        "Crank or D-Pad: Move paddle",
        "A: Launch ball",
        "",
        "Press A to Start"
    }

    local y = 100
    for _, line in ipairs(instructions) do
        local width = gfx.getTextSize(line)
        gfx.drawText(line, (SCREEN_WIDTH - width) / 2, y)
        y += 20
    end

    -- High score
    if highScore > 0 then
        local scoreText = "High Score: " .. highScore
        local scoreWidth = gfx.getTextSize(scoreText)
        gfx.drawText(scoreText, (SCREEN_WIDTH - scoreWidth) / 2, 200)
    end
end

function drawGameOver()
    gfx.clear()

    -- Game Over text
    local gameOverText = "GAME OVER"
    local textWidth = gfx.getTextSize(gameOverText)
    gfx.drawText(gameOverText, (SCREEN_WIDTH - textWidth) / 2, 80)

    -- Final score
    local scoreText = "Score: " .. score
    local scoreWidth = gfx.getTextSize(scoreText)
    gfx.drawText(scoreText, (SCREEN_WIDTH - scoreWidth) / 2, 110)

    -- Level reached
    local levelText = "Level: " .. level
    local levelWidth = gfx.getTextSize(levelText)
    gfx.drawText(levelText, (SCREEN_WIDTH - levelWidth) / 2, 130)

    -- High score
    if score > highScore then
        highScore = score
        local newHighText = "NEW HIGH SCORE!"
        local newHighWidth = gfx.getTextSize(newHighText)
        gfx.drawText(newHighText, (SCREEN_WIDTH - newHighWidth) / 2, 160)
    end

    -- Restart prompt
    if gameOverTimer <= 0 then
        local restartText = "Press A to Restart"
        local restartWidth = gfx.getTextSize(restartText)
        gfx.drawText(restartText, (SCREEN_WIDTH - restartWidth) / 2, 200)
    end
end

function drawUI()
    -- Score
    gfx.drawText("Score: " .. score, 10, 10)

    -- Lives
    local livesText = "Lives: " .. lives
    gfx.drawText(livesText, SCREEN_WIDTH - 80, 10)

    -- Level
    local levelText = "Level: " .. level
    gfx.drawText(levelText, SCREEN_WIDTH / 2 - 30, 10)

    -- Instructions when ball not launched
    if ball.stuck and not ballLaunched then
        local hint = "Press A to launch"
        local hintWidth = gfx.getTextSize(hint)
        gfx.drawText(hint, (SCREEN_WIDTH - hintWidth) / 2, SCREEN_HEIGHT - 30)
    end
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
        -- Update
        updatePaddle()
        updateBall()
        updateParticles()
        updateScreenShake()

        -- Draw with screen shake
        local shakeX, shakeY = getScreenShakeOffset()
        gfx.clear()

        gfx.setDrawOffset(shakeX, shakeY)

        drawBricks()
        drawPaddle()
        drawBall()
        drawParticles()

        gfx.setDrawOffset(0, 0)

        drawUI()

    elseif gameState == STATE_GAME_OVER then
        if gameOverTimer > 0 then
            gameOverTimer -= 1
        end

        drawGameOver()

        if gameOverTimer <= 0 and playdate.buttonJustPressed(playdate.kButtonA) then
            gameState = STATE_MENU
        end
    end

    -- B button toggles FPS (all states)
    if playdate.buttonJustPressed(playdate.kButtonB) then
        local showFPS = not playdate.isFPSDisplayVisible()
        playdate.setShowFPS(showFPS)
    end

    playdate.timer.updateTimers()
end

--[[
    Lifecycle callbacks
]]
function playdate.deviceWillLock()
    -- Save high score
    playdate.datastore.write({highScore = highScore}, "breakout_save")
end

function playdate.gameWillTerminate()
    -- Save high score
    playdate.datastore.write({highScore = highScore}, "breakout_save")
end

--[[
    Initialize game
]]
function init()
    -- Load high score
    local saveData = playdate.datastore.read("breakout_save")
    if saveData and saveData.highScore then
        highScore = saveData.highScore
    end

    math.randomseed(playdate.getSecondsSinceEpoch())

    print("Breakout initialized!")
    print("Crank to move paddle, A to launch ball")
end

-- Start the game
init()
