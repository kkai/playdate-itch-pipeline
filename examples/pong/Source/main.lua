--[[
    PONG - Classic table tennis game for Playdate

    Features:
    - Single player vs AI opponent
    - Two-player local multiplayer
    - Crank-controlled paddle (Player 1)
    - D-pad controlled paddle (Player 2 or AI)
    - Progressive AI difficulty
    - Classic court design
    - Score tracking

    Controls:
    - Crank: Move Player 1 paddle up/down
    - D-Pad Up/Down: Move Player 2 paddle (in 2P mode)
    - A Button: Start game / Serve ball / Select mode
    - B Button: Toggle FPS / Back to menu
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

-- Game states
local STATE_MENU <const> = 0
local STATE_PLAYING <const> = 1
local STATE_SCORED <const> = 2
local STATE_GAME_OVER <const> = 3

-- Game modes
local MODE_1P <const> = 0
local MODE_2P <const> = 1

-- Game configuration
local PADDLE_WIDTH <const> = 8
local PADDLE_HEIGHT <const> = 40
local PADDLE_MARGIN <const> = 20
local PADDLE_SPEED <const> = 5

local BALL_SIZE <const> = 8
local BALL_SPEED_INITIAL <const> = 4
local BALL_SPEED_INCREMENT <const> = 0.2
local BALL_MAX_SPEED <const> = 8

local WINNING_SCORE <const> = 11

-- Game state variables
local gameState = STATE_MENU
local gameMode = MODE_1P
local menuSelection = 0

-- Paddles
local paddle1 = {x = 0, y = 0, targetY = 0, score = 0}
local paddle2 = {x = 0, y = 0, targetY = 0, score = 0}

-- Ball
local ball = {x = 0, y = 0, vx = 0, vy = 0, speed = BALL_SPEED_INITIAL}

-- AI
local aiReactionTime = 0
local aiTargetY = 0
local aiDifficulty = 0.7  -- 0.0 = easy, 1.0 = perfect

-- Timing
local serveDelay = 0
local lastScorer = 1

-- Visual effects
local screenFlash = 0

--[[
    Initialize game objects
]]
function initGame()
    -- Position paddles
    paddle1.x = PADDLE_MARGIN
    paddle1.y = SCREEN_HEIGHT / 2
    paddle1.targetY = paddle1.y
    paddle1.score = 0

    paddle2.x = SCREEN_WIDTH - PADDLE_MARGIN - PADDLE_WIDTH
    paddle2.y = SCREEN_HEIGHT / 2
    paddle2.targetY = paddle2.y
    paddle2.score = 0

    -- Reset ball
    resetBall()

    -- Reset AI
    aiDifficulty = 0.7
end

function resetBall()
    ball.x = SCREEN_WIDTH / 2 - BALL_SIZE / 2
    ball.y = SCREEN_HEIGHT / 2 - BALL_SIZE / 2
    ball.vx = 0
    ball.vy = 0
    ball.speed = BALL_SPEED_INITIAL
    serveDelay = 60  -- 2 seconds at 30fps
end

function serveBall()
    -- Serve toward the player who was scored on
    local direction = lastScorer == 1 and 1 or -1

    -- Random angle between -45 and 45 degrees
    local angle = (math.random() - 0.5) * math.pi / 2

    ball.vx = direction * math.cos(angle) * ball.speed
    ball.vy = math.sin(angle) * ball.speed
end

--[[
    Input handling
]]
function handlePlayer1Input()
    -- Crank control (primary)
    local crankChange = playdate.getCrankChange()
    if crankChange ~= 0 then
        paddle1.targetY += crankChange * 1.5
    end

    -- D-pad control (alternative for Player 1 in 1P mode)
    if gameMode == MODE_1P then
        if playdate.buttonIsPressed(playdate.kButtonUp) then
            paddle1.targetY -= PADDLE_SPEED
        end
        if playdate.buttonIsPressed(playdate.kButtonDown) then
            paddle1.targetY += PADDLE_SPEED
        end
    end

    -- Clamp to screen
    paddle1.targetY = math.max(PADDLE_HEIGHT / 2,
        math.min(SCREEN_HEIGHT - PADDLE_HEIGHT / 2, paddle1.targetY))

    -- Smooth movement
    paddle1.y += (paddle1.targetY - paddle1.y) * 0.3
end

function handlePlayer2Input()
    if gameMode == MODE_2P then
        -- Human player 2 uses D-pad
        if playdate.buttonIsPressed(playdate.kButtonUp) then
            paddle2.targetY -= PADDLE_SPEED
        end
        if playdate.buttonIsPressed(playdate.kButtonDown) then
            paddle2.targetY += PADDLE_SPEED
        end
    else
        -- AI control
        updateAI()
    end

    -- Clamp to screen
    paddle2.targetY = math.max(PADDLE_HEIGHT / 2,
        math.min(SCREEN_HEIGHT - PADDLE_HEIGHT / 2, paddle2.targetY))

    -- Smooth movement
    paddle2.y += (paddle2.targetY - paddle2.y) * 0.3
end

--[[
    AI opponent
]]
function updateAI()
    -- Update reaction timer
    aiReactionTime -= 1

    if aiReactionTime <= 0 then
        -- Predict where ball will be
        if ball.vx > 0 then
            -- Ball coming toward AI
            local predictedY = predictBallY()
            aiTargetY = predictedY

            -- Add some imperfection based on difficulty
            local error = (1 - aiDifficulty) * PADDLE_HEIGHT * 2
            aiTargetY += (math.random() - 0.5) * error
        else
            -- Ball going away, return to center
            aiTargetY = SCREEN_HEIGHT / 2
        end

        -- Reset reaction time based on difficulty
        aiReactionTime = math.floor((1 - aiDifficulty) * 15) + 3
    end

    -- Move toward target
    local diff = aiTargetY - paddle2.targetY
    local maxMove = PADDLE_SPEED * aiDifficulty * 1.2

    if math.abs(diff) > maxMove then
        paddle2.targetY += (diff > 0 and maxMove or -maxMove)
    else
        paddle2.targetY = aiTargetY
    end
end

function predictBallY()
    -- Simple prediction: where will ball be when it reaches paddle?
    if ball.vx <= 0 then
        return ball.y + BALL_SIZE / 2
    end

    local timeToReach = (paddle2.x - ball.x - BALL_SIZE) / ball.vx
    local predictedY = ball.y + ball.vy * timeToReach

    -- Account for bounces
    while predictedY < 0 or predictedY > SCREEN_HEIGHT - BALL_SIZE do
        if predictedY < 0 then
            predictedY = -predictedY
        elseif predictedY > SCREEN_HEIGHT - BALL_SIZE then
            predictedY = 2 * (SCREEN_HEIGHT - BALL_SIZE) - predictedY
        end
    end

    return predictedY + BALL_SIZE / 2
end

--[[
    Ball physics
]]
function updateBall()
    if serveDelay > 0 then
        serveDelay -= 1
        if serveDelay == 0 then
            serveBall()
        end
        return
    end

    -- Move ball
    ball.x += ball.vx
    ball.y += ball.vy

    -- Top/bottom wall collision
    if ball.y < 0 then
        ball.y = 0
        ball.vy = -ball.vy
    elseif ball.y + BALL_SIZE > SCREEN_HEIGHT then
        ball.y = SCREEN_HEIGHT - BALL_SIZE
        ball.vy = -ball.vy
    end

    -- Paddle 1 collision (left)
    if ball.x <= paddle1.x + PADDLE_WIDTH and
       ball.x + BALL_SIZE >= paddle1.x and
       ball.y + BALL_SIZE >= paddle1.y - PADDLE_HEIGHT / 2 and
       ball.y <= paddle1.y + PADDLE_HEIGHT / 2 then

        -- Bounce
        ball.x = paddle1.x + PADDLE_WIDTH
        ball.vx = math.abs(ball.vx)

        -- Add angle based on where it hit the paddle
        local hitPos = (ball.y + BALL_SIZE / 2 - paddle1.y) / (PADDLE_HEIGHT / 2)
        ball.vy = hitPos * ball.speed * 0.8

        -- Speed up
        ball.speed = math.min(BALL_MAX_SPEED, ball.speed + BALL_SPEED_INCREMENT)
        normalizeVelocity()

        screenFlash = 3
    end

    -- Paddle 2 collision (right)
    if ball.x + BALL_SIZE >= paddle2.x and
       ball.x <= paddle2.x + PADDLE_WIDTH and
       ball.y + BALL_SIZE >= paddle2.y - PADDLE_HEIGHT / 2 and
       ball.y <= paddle2.y + PADDLE_HEIGHT / 2 then

        -- Bounce
        ball.x = paddle2.x - BALL_SIZE
        ball.vx = -math.abs(ball.vx)

        -- Add angle based on where it hit the paddle
        local hitPos = (ball.y + BALL_SIZE / 2 - paddle2.y) / (PADDLE_HEIGHT / 2)
        ball.vy = hitPos * ball.speed * 0.8

        -- Speed up
        ball.speed = math.min(BALL_MAX_SPEED, ball.speed + BALL_SPEED_INCREMENT)
        normalizeVelocity()

        screenFlash = 3
    end

    -- Score detection
    if ball.x + BALL_SIZE < 0 then
        -- Player 2 scores
        paddle2.score += 1
        lastScorer = 2
        onScore()
    elseif ball.x > SCREEN_WIDTH then
        -- Player 1 scores
        paddle1.score += 1
        lastScorer = 1
        onScore()
    end
end

function normalizeVelocity()
    local currentSpeed = math.sqrt(ball.vx * ball.vx + ball.vy * ball.vy)
    if currentSpeed > 0 then
        ball.vx = (ball.vx / currentSpeed) * ball.speed
        ball.vy = (ball.vy / currentSpeed) * ball.speed
    end
end

function onScore()
    screenFlash = 10

    -- Check for win
    if paddle1.score >= WINNING_SCORE or paddle2.score >= WINNING_SCORE then
        gameState = STATE_GAME_OVER
    else
        -- Increase AI difficulty slightly
        if gameMode == MODE_1P then
            aiDifficulty = math.min(0.95, aiDifficulty + 0.03)
        end
        resetBall()
    end
end

--[[
    Drawing functions
]]
function drawCourt()
    gfx.setColor(gfx.kColorBlack)

    -- Border
    gfx.drawRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    -- Center line (dashed)
    local dashHeight = 10
    local gapHeight = 8
    for y = 0, SCREEN_HEIGHT, dashHeight + gapHeight do
        gfx.fillRect(SCREEN_WIDTH / 2 - 2, y, 4, dashHeight)
    end

    -- Center circle
    gfx.drawCircleAtPoint(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 30)
end

function drawPaddles()
    gfx.setColor(gfx.kColorBlack)

    -- Paddle 1
    gfx.fillRect(
        paddle1.x,
        paddle1.y - PADDLE_HEIGHT / 2,
        PADDLE_WIDTH,
        PADDLE_HEIGHT
    )

    -- Paddle 2
    gfx.fillRect(
        paddle2.x,
        paddle2.y - PADDLE_HEIGHT / 2,
        PADDLE_WIDTH,
        PADDLE_HEIGHT
    )
end

function drawBall()
    if serveDelay > 0 and serveDelay % 10 < 5 then
        return  -- Blink before serve
    end

    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(ball.x, ball.y, BALL_SIZE, BALL_SIZE)
end

function drawScore()
    gfx.setColor(gfx.kColorBlack)

    -- Player 1 score (left side)
    local score1 = tostring(paddle1.score)
    local width1 = gfx.getTextSize(score1)
    gfx.drawText(score1, SCREEN_WIDTH / 4 - width1 / 2, 20)

    -- Player 2 score (right side)
    local score2 = tostring(paddle2.score)
    local width2 = gfx.getTextSize(score2)
    gfx.drawText(score2, 3 * SCREEN_WIDTH / 4 - width2 / 2, 20)

    -- Labels
    local p1Label = gameMode == MODE_1P and "YOU" or "P1"
    local p2Label = gameMode == MODE_1P and "CPU" or "P2"
    local p1Width = gfx.getTextSize(p1Label)
    local p2Width = gfx.getTextSize(p2Label)
    gfx.drawText(p1Label, SCREEN_WIDTH / 4 - p1Width / 2, 5)
    gfx.drawText(p2Label, 3 * SCREEN_WIDTH / 4 - p2Width / 2, 5)
end

function drawMenu()
    gfx.clear()
    gfx.setColor(gfx.kColorBlack)

    -- Title
    local title = "PONG"
    local titleWidth = gfx.getTextSize(title)
    gfx.drawText(title, (SCREEN_WIDTH - titleWidth) / 2, 50)

    -- Mode selection
    local modes = {"1 Player vs CPU", "2 Players Local"}
    local y = 100

    for i, mode in ipairs(modes) do
        local modeWidth = gfx.getTextSize(mode)
        local x = (SCREEN_WIDTH - modeWidth) / 2

        if i - 1 == menuSelection then
            -- Draw selection indicator
            gfx.fillRect(x - 20, y + 4, 10, 10)
        end

        gfx.drawText(mode, x, y)
        y += 25
    end

    -- Instructions
    local instructions = {
        "",
        "Crank: P1 Paddle",
        "D-Pad: P2 Paddle (in 2P)",
        "",
        "A: Select   Up/Down: Choose"
    }

    y = 160
    for _, line in ipairs(instructions) do
        local width = gfx.getTextSize(line)
        gfx.drawText(line, (SCREEN_WIDTH - width) / 2, y)
        y += 12
    end
end

function drawGameOver()
    gfx.clear()
    gfx.setColor(gfx.kColorBlack)

    -- Winner text
    local winner
    if paddle1.score >= WINNING_SCORE then
        winner = gameMode == MODE_1P and "YOU WIN!" or "PLAYER 1 WINS!"
    else
        winner = gameMode == MODE_1P and "CPU WINS!" or "PLAYER 2 WINS!"
    end

    local winnerWidth = gfx.getTextSize(winner)
    gfx.drawText(winner, (SCREEN_WIDTH - winnerWidth) / 2, 80)

    -- Final score
    local scoreText = paddle1.score .. " - " .. paddle2.score
    local scoreWidth = gfx.getTextSize(scoreText)
    gfx.drawText(scoreText, (SCREEN_WIDTH - scoreWidth) / 2, 110)

    -- Restart prompt
    local restartText = "A: Play Again   B: Menu"
    local restartWidth = gfx.getTextSize(restartText)
    gfx.drawText(restartText, (SCREEN_WIDTH - restartWidth) / 2, 180)
end

--[[
    Main game loop
]]
function playdate.update()
    if gameState == STATE_MENU then
        drawMenu()

        -- Menu navigation
        if playdate.buttonJustPressed(playdate.kButtonUp) then
            menuSelection = (menuSelection - 1) % 2
        elseif playdate.buttonJustPressed(playdate.kButtonDown) then
            menuSelection = (menuSelection + 1) % 2
        end

        -- Start game
        if playdate.buttonJustPressed(playdate.kButtonA) then
            gameMode = menuSelection
            initGame()
            gameState = STATE_PLAYING
        end

    elseif gameState == STATE_PLAYING then
        -- Update
        handlePlayer1Input()
        handlePlayer2Input()
        updateBall()

        -- Screen flash decay
        if screenFlash > 0 then
            screenFlash -= 1
        end

        -- Draw
        if screenFlash > 0 and screenFlash % 2 == 0 then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
        else
            gfx.clear()
            drawCourt()
            drawPaddles()
            drawBall()
            drawScore()
        end

        -- Back to menu
        if playdate.buttonJustPressed(playdate.kButtonB) then
            gameState = STATE_MENU
        end

    elseif gameState == STATE_GAME_OVER then
        drawGameOver()

        if playdate.buttonJustPressed(playdate.kButtonA) then
            initGame()
            gameState = STATE_PLAYING
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            gameState = STATE_MENU
        end
    end

    -- Toggle FPS (in playing state, B goes to menu)
    if gameState == STATE_MENU and playdate.buttonJustPressed(playdate.kButtonB) then
        local showFPS = not playdate.isFPSDisplayVisible()
        playdate.setShowFPS(showFPS)
    end

    playdate.timer.updateTimers()
end

--[[
    Initialize
]]
function init()
    math.randomseed(playdate.getSecondsSinceEpoch())
    print("Pong initialized!")
    print("Crank to move paddle, A to select")
end

init()
