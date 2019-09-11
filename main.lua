cron = require 'cron'

show10plus = false
count10plusSeconds = cron.after(1,function() show10plus = false end)
show2minus = false
count2minusSeconds = cron.after(1,function() show10plus = false end)

function love.load()
    player = love.graphics.newImage("img/player.png")
    bg_image = love.graphics.newImage("img/candy_milk_blue_tile.png")
    blueTileBubbles = love.graphics.newImage("img/candy_milk_blue_tile_bubbles.png")
    chestTile = love.graphics.newImage("img/candy_milk_green_tile_chest.png")
    octopusTile = love.graphics.newImage("img/candy_milk_blue_tile_octopus.png")
    bg_browntile = love.graphics.newImage("img/candy_milk_brown_tile.png")
    bg_water = love.graphics.newImage("img/background.png")
    bg_green_plants = love.graphics.newImage("img/midground.png")
    plus10 = love.graphics.newImage("img/10plus.png")
    minus2 = love.graphics.newImage("img/2minus.png")

    bgMusic = love.audio.newSource("sound/watery_cave_loop.ogg", "stream")
    love.audio.play(bgMusic)
    audioTakeBubbles = love.audio.newSource("sound/Absorb.mp3", "stream")
    audioLooseBubbles = love.audio.newSource("sound/Bide.wav", "stream")

    love.graphics.setNewFont(16)
    mapCounter = 1
    init()
    
end

function love.update(dt)
    if not isPlayerDead() then
        count10plusSeconds:update(dt)
        count2minusSeconds:update(dt)
        if not lockMove then
            if love.keyboard.isDown("right") then
                if isPlayerMovementAllowed(playerPositionXInTilemap + 1, playerPositionYInTilemap) then
                    x = x + moveConstant 
                    lockMove = true
                    keyDirection = "right"
                    playerPositionXInTilemap = playerPositionXInTilemap + 1
                    numberOfMovesLeft = numberOfMovesLeft - 1
                    checkIfPlayerOnBubbles(playerPositionXInTilemap, playerPositionYInTilemap)
                    isPlayerOnOctopus(playerPositionXInTilemap, playerPositionYInTilemap)
                end
            elseif love.keyboard.isDown("left") then
                if isPlayerMovementAllowed(playerPositionXInTilemap - 1, playerPositionYInTilemap) then
                    x = x - moveConstant 
                    lockMove = true
                    keyDirection = "left"
                    playerPositionXInTilemap = playerPositionXInTilemap - 1
                    numberOfMovesLeft = numberOfMovesLeft - 1
                    checkIfPlayerOnBubbles(playerPositionXInTilemap, playerPositionYInTilemap)
                    isPlayerOnOctopus(playerPositionXInTilemap, playerPositionYInTilemap)
                end
            elseif love.keyboard.isDown("up") then
                if isPlayerMovementAllowed(playerPositionXInTilemap, playerPositionYInTilemap - 1) then
                    y = y - moveConstant 
                    lockMove = true
                    keyDirection = "up"
                    playerPositionYInTilemap = playerPositionYInTilemap - 1
                    numberOfMovesLeft = numberOfMovesLeft - 1
                    checkIfPlayerOnBubbles(playerPositionXInTilemap, playerPositionYInTilemap)
                    isPlayerOnOctopus(playerPositionXInTilemap, playerPositionYInTilemap)
                end
            elseif love.keyboard.isDown("down") then
                if isPlayerMovementAllowed(playerPositionXInTilemap, playerPositionYInTilemap + 1) then
                    y = y + moveConstant 
                    lockMove = true
                    keyDirection = "down"
                    playerPositionYInTilemap = playerPositionYInTilemap + 1
                    numberOfMovesLeft = numberOfMovesLeft - 1
                    checkIfPlayerOnBubbles(playerPositionXInTilemap, playerPositionYInTilemap)
                    isPlayerOnOctopus(playerPositionXInTilemap, playerPositionYInTilemap)
                end
            end
        end 
    end

    
end

function love.keyreleased(key) 
    if key == keyDirection then
        lockMove = false
    end
    if key == "y" then
        init()
    end
end

function love.draw()

    local sx = love.graphics.getWidth() / bg_water:getWidth()
    local sy = love.graphics.getHeight() / bg_water:getHeight()
  
    love.graphics.draw(bg_water, 0, 0, 0, sx, sy)
    love.graphics.draw(bg_green_plants, 0, 0, 0, sx, sy)
    if isPlayerDead() then
        love.graphics.print( "GAME OVER", 300, 200)
        love.graphics.print("Play again(y/n)?", 300, 250)

    elseif hasPlayerWon(playerPositionXInTilemap, playerPositionYInTilemap) then
        love.graphics.print( "LEVEL CLEARED", 300, 200)
        mapCounter = mapCounter + 1
        init()
    else
        for i=1,#tilemap do
            --for j till the number of values in this row
            for j=1,#tilemap[i] do
                --if the value on row i, column j equals 1
                if tilemap[i][j] == 1 then
                    --Draw the rectangle
                    love.graphics.draw(bg_image,  j * moveConstant, i * moveConstant)  
                elseif tilemap[i][j] == 2 then
                    love.graphics.draw(bg_browntile,  j * moveConstant, i * moveConstant)  
                elseif tilemap[i][j] == 3 then
                    love.graphics.draw(blueTileBubbles,  j * moveConstant, i * moveConstant) 
                elseif tilemap[i][j] == 4 then 
                    love.graphics.draw(chestTile,  j * moveConstant, i * moveConstant)
                elseif tilemap[i][j] == 5 then 
                    love.graphics.draw(octopusTile,  j * moveConstant, i * moveConstant)
                end 
            end
        end

        love.graphics.draw(player, x, y)
        love.graphics.print("Bubbles: " .. numberOfMovesLeft, 30, 550)
        if show10plus then
            love.graphics.draw(plus10, positionPlusSignX, positionPlusSignY)
        end
        if show2minus then
            love.graphics.draw(minus2, positionMinusSignX, positionMinusSignY)
        end
    end
end

function isPlayerMovementAllowed(positionX, positionY)
    if positionX < 1 or positionX > 24 or positionY < 1 or positionY > 17 then
        return false
    end
    if tilemap[positionY][positionX] == 2 or tilemap[positionY][positionX] == 1 or tilemap[positionY][positionX] == 3 or tilemap[positionY][positionX] == 4 or tilemap[positionY][positionX] == 5 then
        return true
    else
        return false
    end
end

function checkIfPlayerOnBubbles(positionX, positionY)
    if tilemap[positionY][positionX] == 3 then
        numberOfMovesLeft = numberOfMovesLeft + 10
        love.audio.play(audioTakeBubbles)
        tilemap[positionY][positionX] = 1
        show10plus = true      
        positionPlusSignX = playerPositionXInTilemap * moveConstant + 15
        positionPlusSignY = playerPositionYInTilemap * moveConstant - 15
        count10plusSeconds = cron.after(1, function() show10plus = false end)
    end
end

function isPlayerOnOctopus(positionX, positionY)
    if tilemap[positionY][positionX] == 5 then
        numberOfMovesLeft = numberOfMovesLeft - 1
        love.audio.play(audioLooseBubbles)
        tilemap[positionY][positionX] = 1
        show2minus = true
        positionMinusSignX = playerPositionXInTilemap * moveConstant + 15
        positionMinusSignY = playerPositionYInTilemap * moveConstant - 15
        count2minusSeconds = cron.after(1, function() show2minus = false end)
    end
end

function isPlayerDead()
    if numberOfMovesLeft < 1 then
        return true
    else
        return false
    end
end

function hasPlayerWon(positionX, positionY)
    if tilemap[positionY][positionX] == 4 then
        return true
    else
        return false
    end
end

function init()

    moveConstant = 30
    
    lockMove = false
    show10plus = false
    show2minus = false

    numberOfMovesLeft = 10

    if mapCounter == 1 then
        tilemap = {
            {4, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 5, 1, 1, 1},
            {1, 0, 0, 0, 1, 0, 0, 3, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
            {1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1, 3, 1, 1, 1},
            {1, 0, 0, 0, 1, 5, 1, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0},
            {1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0},
            {0, 0, 3, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0},
            {0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0},
            {0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 5, 1, 3, 1},
            {0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1},
            {1, 1, 5, 3, 1, 0, 0, 1, 1, 1, 3, 1, 1, 5, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1},
            {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1},
            {1, 0, 1, 3, 1, 1, 1, 0, 0, 3, 0, 0, 0, 1, 1, 3, 0, 1, 3, 1, 0, 0, 0, 1},
            {1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1},
            {1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 5, 1, 3, 1, 1, 0, 0, 1},
            {1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 5, 0, 0, 0, 1, 0, 0, 1},
            {1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 5, 0, 0, 0, 1, 0, 0, 1},
            {1, 1, 1, 0, 0, 0, 1, 3, 1, 1, 0, 0, 0, 1, 3, 1, 1, 0, 0, 0, 1, 1, 1, 2}
        }
        playerPositionXInTilemap = 24
        playerPositionYInTilemap = 17  
        x = playerPositionXInTilemap * moveConstant + 7
        y = playerPositionYInTilemap * moveConstant + 7
    elseif mapCounter == 2 then
        tilemap = {
            {2, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1},
            {0, 1, 0, 0, 0, 1, 0, 3, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1},
            {1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 3, 1, 1, 1, 1, 3, 1, 1, 1},
            {1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0},
            {1, 1, 0, 0, 1, 0, 0, 1, 0, 5, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0},
            {0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0},
            {0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 5, 1, 3, 1},
            {0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 4, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1},
            {1, 3, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1},
            {1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1},
            {1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 5, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1},
            {1, 0, 1, 3, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 3, 0, 1, 3, 1, 0, 1, 0, 0},
            {1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1},
            {1, 0, 3, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1},
            {5, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1},
            {5, 0, 0, 0, 1, 5, 1, 5, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0},
            {1, 1, 1, 3, 1, 0, 0, 3, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0}
        }
        playerPositionXInTilemap = 1
        playerPositionYInTilemap = 1  
        x = playerPositionXInTilemap * moveConstant + 7
        y = playerPositionYInTilemap * moveConstant + 7
        bg_water = love.graphics.newImage("img/background2.png")
        bg_green_plants = love.graphics.newImage("img/midground2.png")

    else
        tilemap = {
            {1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0},
            {1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1},
            {1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0},
            {1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0},
            {1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1},
            {1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0},
            {1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0},
            {1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1},
            {1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0},
            {1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0},
            {1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1},
            {1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0},
            {1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0},
            {1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1},
            {1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0},
            {1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0},
            {1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1},
        }
        
    end
 end