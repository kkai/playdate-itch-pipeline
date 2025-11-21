-- Space Invaders for Playdate
-- Classic wave-based shooter with crank controls

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

-- Constants
local SCREEN_WIDTH <const> = 400
local SCREEN_HEIGHT <const> = 240

-- Player constants
local PLAYER_WIDTH <const> = 24
local PLAYER_HEIGHT <const> = 12
local PLAYER_Y <const> = 220
local PLAYER_SPEED <const> = 3

-- Alien constants
local ALIEN_ROWS <const> = 5
local ALIEN_COLS <const> = 11
local ALIEN_WIDTH <const> = 16
local ALIEN_HEIGHT <const> = 12
local ALIEN_SPACING_X <const> = 24
local ALIEN_SPACING_Y <const> = 20
local ALIEN_START_X <const> = 40
local ALIEN_START_Y <const> = 40

-- Bullet constants
local BULLET_WIDTH <const> = 2
local BULLET_HEIGHT <const> = 8
local PLAYER_BULLET_SPEED <const> = 8
local ALIEN_BULLET_SPEED <const> = 4

-- Shield constants
local SHIELD_WIDTH <const> = 32
local SHIELD_HEIGHT <const> = 24
local NUM_SHIELDS <const> = 4

-- UFO constants
local UFO_WIDTH <const> = 24
local UFO_HEIGHT <const> = 10
local UFO_SPEED <const> = 2

-- Game state
local gameState = "menu" -- menu, playing, gameover, paused

-- Player
local player = {
    x = SCREEN_WIDTH / 2,
    y = PLAYER_Y,
    lives = 3,
    score = 0,
    canShoot = true,
    shootCooldown = 0
}

-- Aliens
local aliens = {}
local alienDirection = 1 -- 1 = right, -1 = left
local alienMoveTimer = 0
local alienMoveDelay = 60 -- frames between moves
local alienDropAmount = 8
local aliensToMove = {} -- for animated movement

-- Bullets
local playerBullets = {}
local alienBullets = {}

-- Shields
local shields = {}

-- UFO
local ufo = {
    active = false,
    x = 0,
    y = 20,
    direction = 1,
    timer = 0,
    spawnDelay = 1500 -- frames until UFO appears
}

-- Wave tracking
local currentWave = 1
local totalAliensKilled = 0

-- High score
local highScore = 0

-- Visual effects
local explosions = {}
local screenFlash = 0

-- Crank tracking
local lastCrankPosition = 0

-- Initialize shields
local function initShields()
    shields = {}
    local shieldSpacing = SCREEN_WIDTH / (NUM_SHIELDS + 1)

    for i = 1, NUM_SHIELDS do
        local shield = {
            x = shieldSpacing * i - SHIELD_WIDTH / 2,
            y = 180,
            pixels = {}
        }

        -- Create pixel grid for destructible shield
        for py = 1, SHIELD_HEIGHT do
            shield.pixels[py] = {}
            for px = 1, SHIELD_WIDTH do
                -- Create arch shape
                local centerX = SHIELD_WIDTH / 2
                local distFromCenter = math.abs(px - centerX)

                -- Top arch
                if py <= 8 then
                    shield.pixels[py][px] = distFromCenter <= (SHIELD_WIDTH/2 - py/2)
                -- Bottom with notch
                elseif py > SHIELD_HEIGHT - 8 and distFromCenter < 6 then
                    shield.pixels[py][px] = false
                else
                    shield.pixels[py][px] = true
                end
            end
        end

        table.insert(shields, shield)
    end
end

-- Initialize aliens for a wave
local function initAliens()
    aliens = {}

    -- Point values for each row (top to bottom)
    local rowPoints = {30, 20, 20, 10, 10}
    local rowTypes = {3, 2, 2, 1, 1} -- Different visual types

    for row = 1, ALIEN_ROWS do
        for col = 1, ALIEN_COLS do
            local alien = {
                x = ALIEN_START_X + (col - 1) * ALIEN_SPACING_X,
                y = ALIEN_START_Y + (row - 1) * ALIEN_SPACING_Y,
                alive = true,
                type = rowTypes[row],
                points = rowPoints[row],
                frame = 1
            }
            table.insert(aliens, alien)
        end
    end

    -- Adjust speed based on wave
    alienMoveDelay = math.max(10, 60 - (currentWave - 1) * 5)
    alienDirection = 1
end

-- Initialize game
local function initGame()
    player.x = SCREEN_WIDTH / 2
    player.lives = 3
    player.score = 0
    player.canShoot = true
    player.shootCooldown = 0

    currentWave = 1
    totalAliensKilled = 0

    playerBullets = {}
    alienBullets = {}
    explosions = {}

    ufo.active = false
    ufo.timer = 0

    initShields()
    initAliens()

    lastCrankPosition = playdate.getCrankPosition()
end

-- Create explosion effect
local function createExplosion(x, y, size)
    table.insert(explosions, {
        x = x,
        y = y,
        size = size,
        life = 1.0,
        particles = {}
    })

    -- Create particles
    local exp = explosions[#explosions]
    for i = 1, size * 4 do
        local angle = math.random() * math.pi * 2
        local speed = math.random() * 3 + 1
        table.insert(exp.particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed
        })
    end
end

-- Damage shield at position
local function damageShield(shield, hitX, hitY, radius)
    local localX = math.floor(hitX - shield.x)
    local localY = math.floor(hitY - shield.y)

    for py = math.max(1, localY - radius), math.min(SHIELD_HEIGHT, localY + radius) do
        for px = math.max(1, localX - radius), math.min(SHIELD_WIDTH, localX + radius) do
            local dist = math.sqrt((px - localX)^2 + (py - localY)^2)
            if dist <= radius then
                shield.pixels[py][px] = false
            end
        end
    end
end

-- Check if shield has any pixels left
local function shieldHasPixels(shield)
    for py = 1, SHIELD_HEIGHT do
        for px = 1, SHIELD_WIDTH do
            if shield.pixels[py][px] then
                return true
            end
        end
    end
    return false
end

-- Player shooting
local function playerShoot()
    if player.canShoot and #playerBullets < 2 then
        table.insert(playerBullets, {
            x = player.x,
            y = player.y - PLAYER_HEIGHT/2,
            active = true
        })
        player.canShoot = false
        player.shootCooldown = 15
    end
end

-- Alien shooting
local function alienShoot()
    -- Find alive aliens in each column
    local bottomAliens = {}

    for i, alien in ipairs(aliens) do
        if alien.alive then
            local col = ((i - 1) % ALIEN_COLS) + 1
            if not bottomAliens[col] or alien.y > bottomAliens[col].y then
                bottomAliens[col] = alien
            end
        end
    end

    -- Random alien shoots
    local shooters = {}
    for col, alien in pairs(bottomAliens) do
        table.insert(shooters, alien)
    end

    if #shooters > 0 and math.random() < 0.02 + (currentWave * 0.005) then
        local shooter = shooters[math.random(#shooters)]
        table.insert(alienBullets, {
            x = shooter.x + ALIEN_WIDTH/2,
            y = shooter.y + ALIEN_HEIGHT,
            active = true
        })
    end
end

-- Count alive aliens
local function countAliveAliens()
    local count = 0
    for _, alien in ipairs(aliens) do
        if alien.alive then
            count = count + 1
        end
    end
    return count
end

-- Get alien bounds
local function getAlienBounds()
    local minX, maxX, maxY = SCREEN_WIDTH, 0, 0

    for _, alien in ipairs(aliens) do
        if alien.alive then
            if alien.x < minX then minX = alien.x end
            if alien.x + ALIEN_WIDTH > maxX then maxX = alien.x + ALIEN_WIDTH end
            if alien.y + ALIEN_HEIGHT > maxY then maxY = alien.y + ALIEN_HEIGHT end
        end
    end

    return minX, maxX, maxY
end

-- Move aliens
local function moveAliens()
    local minX, maxX, maxY = getAlienBounds()
    local shouldDrop = false

    -- Check if aliens hit edge
    if alienDirection == 1 and maxX >= SCREEN_WIDTH - 10 then
        shouldDrop = true
        alienDirection = -1
    elseif alienDirection == -1 and minX <= 10 then
        shouldDrop = true
        alienDirection = 1
    end

    -- Move all aliens
    for _, alien in ipairs(aliens) do
        if alien.alive then
            if shouldDrop then
                alien.y = alien.y + alienDropAmount
            else
                alien.x = alien.x + alienDirection * 4
            end
            -- Toggle animation frame
            alien.frame = alien.frame == 1 and 2 or 1
        end
    end

    -- Check if aliens reached bottom
    if maxY >= PLAYER_Y - 20 then
        gameState = "gameover"
        if player.score > highScore then
            highScore = player.score
        end
    end

    -- Speed up as fewer aliens remain
    local aliveCount = countAliveAliens()
    if aliveCount > 0 then
        alienMoveDelay = math.max(2, math.floor(60 * aliveCount / (ALIEN_ROWS * ALIEN_COLS)) - (currentWave - 1) * 3)
    end
end

-- Update UFO
local function updateUFO()
    if not ufo.active then
        ufo.timer = ufo.timer + 1
        if ufo.timer >= ufo.spawnDelay then
            ufo.active = true
            ufo.direction = math.random() > 0.5 and 1 or -1
            ufo.x = ufo.direction == 1 and -UFO_WIDTH or SCREEN_WIDTH
            ufo.timer = 0
        end
    else
        ufo.x = ufo.x + UFO_SPEED * ufo.direction

        -- UFO left screen
        if (ufo.direction == 1 and ufo.x > SCREEN_WIDTH) or
           (ufo.direction == -1 and ufo.x < -UFO_WIDTH) then
            ufo.active = false
        end
    end
end

-- Check collision between point and rectangle
local function pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

-- Check bullet vs shield collision
local function bulletHitsShield(bullet, shield)
    local localX = math.floor(bullet.x - shield.x)
    local localY = math.floor(bullet.y - shield.y)

    if localX >= 1 and localX <= SHIELD_WIDTH and localY >= 1 and localY <= SHIELD_HEIGHT then
        -- Check nearby pixels
        for dy = -1, 1 do
            for dx = -1, 1 do
                local px = localX + dx
                local py = localY + dy
                if px >= 1 and px <= SHIELD_WIDTH and py >= 1 and py <= SHIELD_HEIGHT then
                    if shield.pixels[py][px] then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Update game logic
local function updateGame()
    if gameState ~= "playing" then return end

    -- Update screen flash
    if screenFlash > 0 then
        screenFlash = screenFlash - 0.1
    end

    -- Update shoot cooldown
    if not player.canShoot then
        player.shootCooldown = player.shootCooldown - 1
        if player.shootCooldown <= 0 then
            player.canShoot = true
        end
    end

    -- Player movement with crank
    local crankPosition = playdate.getCrankPosition()
    local crankChange = crankPosition - lastCrankPosition

    -- Handle wraparound
    if crankChange > 180 then
        crankChange = crankChange - 360
    elseif crankChange < -180 then
        crankChange = crankChange + 360
    end

    player.x = player.x + crankChange * PLAYER_SPEED * 0.1
    lastCrankPosition = crankPosition

    -- D-pad movement as alternative
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        player.x = player.x - PLAYER_SPEED
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        player.x = player.x + PLAYER_SPEED
    end

    -- Clamp player position
    player.x = math.max(PLAYER_WIDTH/2, math.min(SCREEN_WIDTH - PLAYER_WIDTH/2, player.x))

    -- Shooting
    if playdate.buttonJustPressed(playdate.kButtonA) then
        playerShoot()
    end

    -- Update player bullets
    for i = #playerBullets, 1, -1 do
        local bullet = playerBullets[i]
        bullet.y = bullet.y - PLAYER_BULLET_SPEED

        -- Off screen
        if bullet.y < 0 then
            table.remove(playerBullets, i)
        else
            -- Check alien collisions
            local hitAlien = false
            for _, alien in ipairs(aliens) do
                if alien.alive and pointInRect(bullet.x, bullet.y,
                    alien.x, alien.y, ALIEN_WIDTH, ALIEN_HEIGHT) then
                    alien.alive = false
                    player.score = player.score + alien.points
                    totalAliensKilled = totalAliensKilled + 1
                    createExplosion(alien.x + ALIEN_WIDTH/2, alien.y + ALIEN_HEIGHT/2, 3)
                    hitAlien = true
                    break
                end
            end

            -- Check UFO collision
            if not hitAlien and ufo.active and pointInRect(bullet.x, bullet.y,
                ufo.x, ufo.y, UFO_WIDTH, UFO_HEIGHT) then
                ufo.active = false
                local ufoPoints = math.random(1, 3) * 50 + 50 -- 100, 150, or 200
                player.score = player.score + ufoPoints
                createExplosion(ufo.x + UFO_WIDTH/2, ufo.y + UFO_HEIGHT/2, 4)
                screenFlash = 1
                hitAlien = true
            end

            -- Check shield collisions
            if not hitAlien then
                for _, shield in ipairs(shields) do
                    if bulletHitsShield(bullet, shield) then
                        damageShield(shield, bullet.x, bullet.y, 3)
                        hitAlien = true
                        break
                    end
                end
            end

            if hitAlien then
                table.remove(playerBullets, i)
            end
        end
    end

    -- Alien movement
    alienMoveTimer = alienMoveTimer + 1
    if alienMoveTimer >= alienMoveDelay then
        moveAliens()
        alienMoveTimer = 0
    end

    -- Alien shooting
    alienShoot()

    -- Update alien bullets
    for i = #alienBullets, 1, -1 do
        local bullet = alienBullets[i]
        bullet.y = bullet.y + ALIEN_BULLET_SPEED

        -- Off screen
        if bullet.y > SCREEN_HEIGHT then
            table.remove(alienBullets, i)
        else
            local hitSomething = false

            -- Check player collision
            if pointInRect(bullet.x, bullet.y,
                player.x - PLAYER_WIDTH/2, player.y - PLAYER_HEIGHT/2,
                PLAYER_WIDTH, PLAYER_HEIGHT) then
                player.lives = player.lives - 1
                createExplosion(player.x, player.y, 5)
                screenFlash = 1
                hitSomething = true

                if player.lives <= 0 then
                    gameState = "gameover"
                    if player.score > highScore then
                        highScore = player.score
                    end
                end
            end

            -- Check shield collisions
            if not hitSomething then
                for _, shield in ipairs(shields) do
                    if bulletHitsShield(bullet, shield) then
                        damageShield(shield, bullet.x, bullet.y, 2)
                        hitSomething = true
                        break
                    end
                end
            end

            if hitSomething then
                table.remove(alienBullets, i)
            end
        end
    end

    -- Update UFO
    updateUFO()

    -- Update explosions
    for i = #explosions, 1, -1 do
        local exp = explosions[i]
        exp.life = exp.life - 0.05

        for _, p in ipairs(exp.particles) do
            p.x = p.x + p.vx
            p.y = p.y + p.vy
            p.vy = p.vy + 0.1 -- gravity
        end

        if exp.life <= 0 then
            table.remove(explosions, i)
        end
    end

    -- Check wave complete
    if countAliveAliens() == 0 then
        currentWave = currentWave + 1
        initAliens()
        -- Bonus points for clearing wave
        player.score = player.score + currentWave * 100
        screenFlash = 1
    end

    -- Remove empty shields
    for i = #shields, 1, -1 do
        if not shieldHasPixels(shields[i]) then
            table.remove(shields, i)
        end
    end
end

-- Draw player ship
local function drawPlayer()
    gfx.setColor(gfx.kColorWhite)

    -- Ship body
    local x = player.x - PLAYER_WIDTH/2
    local y = player.y - PLAYER_HEIGHT/2

    gfx.fillRect(x + 4, y + 4, PLAYER_WIDTH - 8, PLAYER_HEIGHT - 4)
    gfx.fillRect(x + 8, y + 2, PLAYER_WIDTH - 16, 2)
    gfx.fillRect(x + PLAYER_WIDTH/2 - 2, y, 4, 4)

    -- Wings
    gfx.fillRect(x, y + 6, 4, PLAYER_HEIGHT - 6)
    gfx.fillRect(x + PLAYER_WIDTH - 4, y + 6, 4, PLAYER_HEIGHT - 6)
end

-- Draw alien based on type and frame
local function drawAlien(alien)
    local x = alien.x
    local y = alien.y

    gfx.setColor(gfx.kColorWhite)

    if alien.type == 1 then
        -- Bottom alien (squid)
        if alien.frame == 1 then
            gfx.fillRect(x + 6, y, 4, 2)
            gfx.fillRect(x + 4, y + 2, 8, 2)
            gfx.fillRect(x + 2, y + 4, 12, 4)
            gfx.fillRect(x + 4, y + 8, 2, 2)
            gfx.fillRect(x + 10, y + 8, 2, 2)
            gfx.fillRect(x + 2, y + 10, 4, 2)
            gfx.fillRect(x + 10, y + 10, 4, 2)
        else
            gfx.fillRect(x + 6, y, 4, 2)
            gfx.fillRect(x + 4, y + 2, 8, 2)
            gfx.fillRect(x + 2, y + 4, 12, 4)
            gfx.fillRect(x + 2, y + 8, 2, 2)
            gfx.fillRect(x + 12, y + 8, 2, 2)
            gfx.fillRect(x + 4, y + 10, 3, 2)
            gfx.fillRect(x + 9, y + 10, 3, 2)
        end
    elseif alien.type == 2 then
        -- Middle alien (crab)
        if alien.frame == 1 then
            gfx.fillRect(x + 4, y, 8, 2)
            gfx.fillRect(x + 2, y + 2, 12, 4)
            gfx.fillRect(x, y + 6, 16, 4)
            gfx.fillRect(x + 2, y + 10, 2, 2)
            gfx.fillRect(x + 12, y + 10, 2, 2)
        else
            gfx.fillRect(x + 4, y, 8, 2)
            gfx.fillRect(x + 2, y + 2, 12, 4)
            gfx.fillRect(x, y + 6, 16, 4)
            gfx.fillRect(x, y + 10, 2, 2)
            gfx.fillRect(x + 14, y + 10, 2, 2)
        end
    else
        -- Top alien (octopus)
        if alien.frame == 1 then
            gfx.fillRect(x + 6, y, 4, 2)
            gfx.fillRect(x + 4, y + 2, 8, 2)
            gfx.fillRect(x + 2, y + 4, 12, 4)
            gfx.fillRect(x, y + 8, 4, 2)
            gfx.fillRect(x + 12, y + 8, 4, 2)
            gfx.fillRect(x + 4, y + 10, 2, 2)
            gfx.fillRect(x + 10, y + 10, 2, 2)
        else
            gfx.fillRect(x + 6, y, 4, 2)
            gfx.fillRect(x + 4, y + 2, 8, 2)
            gfx.fillRect(x + 2, y + 4, 12, 4)
            gfx.fillRect(x + 2, y + 8, 4, 2)
            gfx.fillRect(x + 10, y + 8, 4, 2)
            gfx.fillRect(x + 2, y + 10, 2, 2)
            gfx.fillRect(x + 12, y + 10, 2, 2)
        end
    end

    -- Eyes (black)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x + 5, y + 4, 2, 2)
    gfx.fillRect(x + 9, y + 4, 2, 2)
end

-- Draw UFO
local function drawUFO()
    if not ufo.active then return end

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(ufo.x + 8, ufo.y, 8, 4)
    gfx.fillRect(ufo.x + 4, ufo.y + 4, 16, 4)
    gfx.fillRect(ufo.x, ufo.y + 6, 24, 4)
end

-- Draw shield
local function drawShield(shield)
    gfx.setColor(gfx.kColorWhite)

    for py = 1, SHIELD_HEIGHT do
        for px = 1, SHIELD_WIDTH do
            if shield.pixels[py][px] then
                gfx.fillRect(shield.x + px - 1, shield.y + py - 1, 1, 1)
            end
        end
    end
end

-- Draw game
local function drawGame()
    gfx.clear(gfx.kColorBlack)

    -- Screen flash effect
    if screenFlash > 0 then
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(1 - screenFlash, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    end

    -- Draw shields
    for _, shield in ipairs(shields) do
        drawShield(shield)
    end

    -- Draw aliens
    for _, alien in ipairs(aliens) do
        if alien.alive then
            drawAlien(alien)
        end
    end

    -- Draw UFO
    drawUFO()

    -- Draw player
    drawPlayer()

    -- Draw player bullets
    gfx.setColor(gfx.kColorWhite)
    for _, bullet in ipairs(playerBullets) do
        gfx.fillRect(bullet.x - BULLET_WIDTH/2, bullet.y - BULLET_HEIGHT/2,
            BULLET_WIDTH, BULLET_HEIGHT)
    end

    -- Draw alien bullets
    for _, bullet in ipairs(alienBullets) do
        -- Zigzag pattern
        local offset = math.sin(bullet.y * 0.3) * 2
        gfx.fillRect(bullet.x - 1 + offset, bullet.y - 2, 2, 4)
        gfx.fillRect(bullet.x - 1 - offset, bullet.y + 2, 2, 4)
    end

    -- Draw explosions
    gfx.setColor(gfx.kColorWhite)
    for _, exp in ipairs(explosions) do
        for _, p in ipairs(exp.particles) do
            if exp.life > 0 then
                gfx.fillRect(p.x - 1, p.y - 1, 2, 2)
            end
        end
    end

    -- Draw HUD
    gfx.setColor(gfx.kColorWhite)
    gfx.drawText("SCORE: " .. player.score, 5, 5)
    gfx.drawText("WAVE: " .. currentWave, SCREEN_WIDTH/2 - 30, 5)
    gfx.drawText("HI: " .. highScore, SCREEN_WIDTH - 80, 5)

    -- Draw lives
    for i = 1, player.lives do
        local lx = SCREEN_WIDTH - 30 - (i - 1) * 20
        gfx.fillRect(lx, 228, 12, 6)
        gfx.fillRect(lx + 4, 225, 4, 3)
    end
end

-- Draw menu
local function drawMenu()
    gfx.clear(gfx.kColorBlack)

    gfx.setColor(gfx.kColorWhite)

    -- Title
    gfx.drawText("*SPACE INVADERS*", SCREEN_WIDTH/2 - 70, 40)

    -- Draw sample aliens
    local sampleAlien = {x = 160, y = 80, type = 3, frame = 1}
    drawAlien(sampleAlien)
    gfx.drawText("= 30 PTS", 200, 82)

    sampleAlien.y = 105
    sampleAlien.type = 2
    drawAlien(sampleAlien)
    gfx.drawText("= 20 PTS", 200, 107)

    sampleAlien.y = 130
    sampleAlien.type = 1
    drawAlien(sampleAlien)
    gfx.drawText("= 10 PTS", 200, 132)

    -- UFO
    gfx.fillRect(160, 155, 16, 8)
    gfx.drawText("= ??? PTS", 200, 155)

    -- Instructions
    gfx.drawText("CRANK or D-PAD: Move", 100, 185)
    gfx.drawText("A: Fire", 100, 205)

    gfx.drawText("Press A to Start", SCREEN_WIDTH/2 - 60, 225)

    if highScore > 0 then
        gfx.drawText("High Score: " .. highScore, SCREEN_WIDTH/2 - 50, 60)
    end
end

-- Draw game over
local function drawGameOver()
    gfx.clear(gfx.kColorBlack)

    gfx.setColor(gfx.kColorWhite)
    gfx.drawText("*GAME OVER*", SCREEN_WIDTH/2 - 50, 80)
    gfx.drawText("Score: " .. player.score, SCREEN_WIDTH/2 - 40, 110)
    gfx.drawText("Wave: " .. currentWave, SCREEN_WIDTH/2 - 30, 130)
    gfx.drawText("Aliens Defeated: " .. totalAliensKilled, SCREEN_WIDTH/2 - 60, 150)

    if player.score >= highScore and player.score > 0 then
        gfx.drawText("*NEW HIGH SCORE!*", SCREEN_WIDTH/2 - 65, 175)
    end

    gfx.drawText("Press A to Continue", SCREEN_WIDTH/2 - 65, 210)
end

-- Main update
function playdate.update()
    if gameState == "menu" then
        drawMenu()
        if playdate.buttonJustPressed(playdate.kButtonA) then
            initGame()
            gameState = "playing"
        end
    elseif gameState == "playing" then
        updateGame()
        drawGame()
    elseif gameState == "gameover" then
        drawGameOver()
        if playdate.buttonJustPressed(playdate.kButtonA) then
            gameState = "menu"
        end
    end

    playdate.timer.updateTimers()
end

-- System callbacks
function playdate.gameWillTerminate()
    -- Save high score
    local gameData = {
        highScore = highScore
    }
    playdate.datastore.write(gameData)
end

function playdate.deviceWillLock()
    -- Save high score
    local gameData = {
        highScore = highScore
    }
    playdate.datastore.write(gameData)
end

function playdate.deviceWillSleep()
    -- Save high score
    local gameData = {
        highScore = highScore
    }
    playdate.datastore.write(gameData)
end

-- Load saved data on start
local savedData = playdate.datastore.read()
if savedData then
    highScore = savedData.highScore or 0
end
