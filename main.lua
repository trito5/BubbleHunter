cron = require 'cron'

function love.load()
   
    player = love.graphics.newImage("img/player.png")
    blueTile = love.graphics.newImage("img/candy_milk_blue_tile.png")
    blueTileBubbles = love.graphics.newImage("img/candy_milk_blue_tile_bubbles.png")
    chestTile = love.graphics.newImage("img/candy_milk_green_tile_chest.png")
    octopusTile = love.graphics.newImage("img/candy_milk_blue_tile_octopus.png")
    brownTile = love.graphics.newImage("img/candy_milk_brown_tile.png")
    blackBox = love.graphics.newImage("img/blackBox.png")
    endBox = love.graphics.newImage("img/endBox.png") 
    levelCleared = love.graphics.newImage("img/levelCleared.png")
    gameOver = love.graphics.newImage("img/gameOver.png")
    bgGreenPlants = love.graphics.newImage("img/titlescreen.png")
    bgWater = love.graphics.newImage("img/titlescreen.png")
    plus10 = love.graphics.newImage("img/10plus.png")
    minus2 = love.graphics.newImage("img/2minus.png")

    bgMusic = love.audio.newSource("sound/watery_cave_loop.ogg", "stream")
    audioTakeBubbles = love.audio.newSource("sound/Absorb.mp3", "stream")
    audioLooseBubbles = love.audio.newSource("sound/Bide.wav", "stream")
    audioLevelCleared = love.audio.newSource("sound/Absorb_part_2.mp3", "stream")
    fanfare = love.audio.newSource("sound/Theme1.wav", "stream")

    count10plusSeconds = cron.after(1,function() show10plus = false end)
    count2minusSeconds = cron.after(1,function() show10plus = false end)

    love.graphics.setNewFont(16)
    mapCounter = 0
    init()
    
end

function love.update(dt)
    if mapCounter == 0 then
        if love.keyboard.isDown("p") then 
            mapCounter = 1
            init()
        end
    else
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
                        playerMovementChecks()
                    end
                elseif love.keyboard.isDown("left") then
                    if isPlayerMovementAllowed(playerPositionXInTilemap - 1, playerPositionYInTilemap) then
                        x = x - moveConstant 
                        lockMove = true
                        keyDirection = "left"
                        playerPositionXInTilemap = playerPositionXInTilemap - 1
                        playerMovementChecks()
                    end
                elseif love.keyboard.isDown("up") then
                    if isPlayerMovementAllowed(playerPositionXInTilemap, playerPositionYInTilemap - 1) then
                        y = y - moveConstant 
                        lockMove = true
                        keyDirection = "up"
                        playerPositionYInTilemap = playerPositionYInTilemap - 1
                        playerMovementChecks()
                    end
                elseif love.keyboard.isDown("down") then
                    if isPlayerMovementAllowed(playerPositionXInTilemap, playerPositionYInTilemap + 1) then
                        y = y + moveConstant 
                        lockMove = true
                        keyDirection = "down"
                        playerPositionYInTilemap = playerPositionYInTilemap + 1
                        playerMovementChecks()
                    end
                end
            end 
        end
    end
end

function love.keyreleased(key) 

    if key == keyDirection then
        lockMove = false
    end
    if isPlayerDead() or mapCounter > 3 then
        if key == "y" then
            if mapCounter > 4 then
                mapCounter = 1
                love.audio.stop(fanfare)
                bgMusic:setLooping(true)
                bgMusic:play()
            end
            init()
        elseif key == "n" then
            mapCounter = 0
            bgGreenPlants = love.graphics.newImage("img/titlescreen.png")
            if mapCounter > 3 then
                love.audio.stop(fanfare)
                bgMusic:setLooping(true)
                bgMusic:play()
            end
            init()
        
        end
    end
    
end

function love.draw()

    local sx = love.graphics.getWidth() / bgWater:getWidth()
    local sy = love.graphics.getHeight() / bgWater:getHeight()
   
    love.graphics.draw(bgWater, 0, 0, 0, sx, sy)
    love.graphics.draw(bgGreenPlants, 0, 0, 0, sx, sy)
     
    if mapCounter < 1 then  

        love.graphics.draw(bgGreenPlants, 0, 0)
        love.graphics.print("Don't run out of air bubbles!", 280, 220)
        
        love.graphics.setColor(255,255,255,0.8)
        love.graphics.draw(blackBox, 0, 0)
        love.graphics.setColor(255,255,255,100)
        love.graphics.draw(blueTileBubbles, 300, 330)
        love.graphics.print("+10 air bubbles.", 345, 335)
        love.graphics.draw(octopusTile, 300, 370)
        love.graphics.print("-2 air bubbles.", 345, 375)
        love.graphics.draw(chestTile, 300, 410)
        love.graphics.print("Reach the chest.", 345, 415)
        love.graphics.print("Press P to play", 330, 480)

    elseif mapCounter > 4 then
        love.graphics.draw(levelCleared, 90, 100)
        love.graphics.setColor(255, 255, 255, 0.5)
        love.graphics.draw(endBox, -5, 45)
        love.graphics.setColor(255, 255, 255, 1)
        love.graphics.print("Thank you for playing!", 300, 300)
        love.graphics.print("Play again (y/n)?", 325, 400)
        
        love.graphics.print("This game was made in Kodsnacks spelsylt 2019", 200, 320)
        love.graphics.setNewFont(12)
        love.graphics.print("Credit sound: Pascal Belisle and Magic_Spark", 250, 555)
        love.graphics.print("Credit graphic: Luiz Zuno, Shikikashi's Fantasi Icons Pack and Candy Milk tileset", 150, 569)
        love.graphics.setNewFont(16)
       
        love.audio.play(fanfare)
        love.audio.stop(bgMusic)
    else 
        if hasPlayerWon(playerPositionXInTilemap, playerPositionYInTilemap) then
            mapCounter = mapCounter + 1
            love.audio.play(audioLevelCleared)
            init()
        elseif isPlayerDead() then
            love.graphics.draw(gameOver, 100, 100)
            love.graphics.print("Play again(y/n)?", 330, 260)
        else
            for i=1,#tilemap do
                for j=1,#tilemap[i] do
                    if tilemap[i][j] == 1 then
                        love.graphics.draw(blueTile,  11 + j * moveConstant, i * moveConstant)  
                    elseif tilemap[i][j] == 2 then
                        love.graphics.draw(brownTile, 11 + j * moveConstant, i * moveConstant)  
                    elseif tilemap[i][j] == 3 then
                        love.graphics.draw(blueTileBubbles, 11 + j * moveConstant, i * moveConstant) 
                    elseif tilemap[i][j] == 4 then 
                        love.graphics.draw(chestTile, 11 + j * moveConstant, i * moveConstant)
                    elseif tilemap[i][j] == 5 then 
                        love.graphics.draw(octopusTile, 11 + j * moveConstant, i * moveConstant)
                    end 
                end
            end

            love.graphics.draw(player, x + 11, y)
            love.graphics.print("Bubbles: " .. numberOfMovesLeft, 41, 550)
            love.graphics.print("Map: " .. mapCounter, 700, 550)
            if show10plus then
                love.graphics.draw(plus10, positionPlusSignX, positionPlusSignY)
            end
            if show2minus then
                love.graphics.draw(minus2, positionMinusSignX, positionMinusSignY)
            end
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
        positionPlusSignX = playerPositionXInTilemap * moveConstant + 25
        positionPlusSignY = playerPositionYInTilemap * moveConstant - 15
        count10plusSeconds = cron.after(1, function() show10plus = false end)
    end
end

function checkIfPlayerOnOctopus(positionX, positionY)
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

function playerMovementChecks()
    numberOfMovesLeft = numberOfMovesLeft - 1
    checkIfPlayerOnBubbles(playerPositionXInTilemap, playerPositionYInTilemap)
    checkIfPlayerOnOctopus(playerPositionXInTilemap, playerPositionYInTilemap)
end

function init()
    moveConstant = 30
    
    lockMove = false
    show10plus = false
    show2minus = false

    numberOfMovesLeft = 10

    if mapCounter == 0 then
        bgMusic:setLooping(true)
        bgMusic:play()
        love.audio.stop(fanfare)
        tilemap = {}
    elseif mapCounter == 1 then
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
        bgWater = love.graphics.newImage("img/background.png")
        bgGreenPlants = love.graphics.newImage("img/midground.png")
        playerPositionXInTilemap = 24
        playerPositionYInTilemap = 17  
        x = playerPositionXInTilemap * moveConstant + 7
        y = playerPositionYInTilemap * moveConstant + 7
    elseif mapCounter == 2 then
        tilemap = {
            {2, 1, 1, 5, 1, 3, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 5, 5, 1, 3, 1, 1},
            {0, 1, 0, 0, 0, 1, 0, 3, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1},
            {1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 5, 1, 1, 1, 5, 1},
            {1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 3, 1, 0, 0, 1, 0, 0, 0, 1, 0},
            {1, 3, 0, 0, 1, 0, 0, 1, 0, 5, 0, 1, 1, 1, 0, 0, 1, 5, 1, 0, 1, 1, 1, 0},
            {0, 1, 1, 0, 5, 5, 1, 1, 5, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0},
            {0, 0, 1, 5, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 5, 1, 3, 1},
            {0, 0, 0, 0, 1, 5, 1, 0, 0, 1, 0, 4, 0, 0, 0, 5, 0, 0, 1, 0, 0, 0, 0, 1},
            {1, 3, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 5, 0, 0, 1, 5, 1, 1, 0, 1},
            {1, 0, 0, 1, 0, 0, 3, 1, 0, 3, 0, 1, 0, 1, 1, 5, 0, 0, 0, 1, 0, 1, 0, 1},
            {1, 0, 0, 1, 0, 0, 0, 5, 0, 1, 5, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 5, 1, 1},
            {1, 0, 1, 5, 1, 5, 1, 1, 1, 0, 0, 0, 0, 5, 1, 3, 0, 1, 3, 1, 0, 1, 0, 0},
            {1, 0, 5, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 3, 1, 1},
            {1, 0, 3, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 5, 1, 1, 0, 0, 5},
            {5, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 5, 0, 1, 1, 1, 3, 0, 0, 0, 1, 0, 1, 1},
            {1, 0, 0, 0, 1, 5, 1, 5, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0},
            {1, 1, 1, 3, 1, 0, 0, 3, 1, 1, 5, 1, 0, 0, 0, 0, 1, 5, 1, 1, 5, 1, 1, 0}
        }
        playerPositionXInTilemap = 1
        playerPositionYInTilemap = 1  
        x = playerPositionXInTilemap * moveConstant + 7
        y = playerPositionYInTilemap * moveConstant + 7
        bgWater = love.graphics.newImage("img/background2.png")
        bgGreenPlants = love.graphics.newImage("img/midground2.png")

    elseif mapCounter == 3 then
        tilemap = {
            {0, 0, 0, 0, 1, 3, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 5, 1, 1, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 1, 0, 0, 5, 0, 0, 4, 1, 5, 5, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0},
            {0, 1, 5, 1, 1, 0, 0, 5, 5, 5, 1, 0, 0, 1, 1, 5, 1, 0, 0, 1, 1, 5, 1, 0, 0},
            {0, 1, 0, 0, 5, 1, 1, 5, 0, 0, 5, 0, 0, 1, 0, 0, 1, 1, 3, 5, 0, 0, 3, 0, 0},
            {0, 3, 0, 0, 1, 0, 0, 5, 0, 0, 5, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0},
            {0, 1, 1, 5, 1, 0, 0, 5, 1, 1, 5, 0, 0, 5, 1, 1, 5, 0, 0, 1, 1, 1, 1, 0, 0},
            {0, 1, 0, 0, 5, 1, 1, 1, 0, 0, 5, 0, 0, 5, 0, 0, 1, 1, 1, 5, 0, 0, 1, 0, 0},
            {0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 2, 1, 1, 0, 0, 5, 0, 0, 1, 0, 0, 5, 0, 0},
            {0, 5, 1, 1, 1, 0, 0, 1, 5, 1, 5, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0},
            {0, 1, 0, 0, 5, 1, 3, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 3, 1, 1, 0, 0, 1, 0, 0},
            {0, 1, 0, 0, 1, 0, 0, 5, 0, 0, 5, 1, 1, 5, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0},
            {0, 1, 1, 5, 1, 0, 0, 5, 1, 1, 1, 0, 0, 5, 1, 1, 1, 0, 0, 5, 1, 1, 5, 0, 0},
            {0, 5, 0, 0, 1, 5, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0},
            {0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 5, 1, 5, 0, 0, 5, 0, 0, 1, 0, 0, 1, 0, 0},
            {0, 3, 1, 1, 1, 0, 0, 5, 1, 1, 3, 0, 0, 3, 1, 1, 1, 0, 0, 5, 1, 1, 3, 0, 0},
            {0, 0, 0, 0, 5, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 5, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        }
        playerPositionXInTilemap = 12
        playerPositionYInTilemap = 8  
        x = playerPositionXInTilemap * moveConstant + 7
        y = playerPositionYInTilemap * moveConstant + 7
        bgWater = love.graphics.newImage("img/background3.png")
        bgGreenPlants = love.graphics.newImage("img/midground3.png")  
    elseif mapCounter == 4 then
        tilemap = {
            {5, 5, 1, 5, 1, 3, 1, 5, 1, 1, 5, 1, 1, 5, 1, 1, 1, 1, 1, 1, 1, 5, 1, 1, 0},
            {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 3, 0},
            {3, 0, 3, 1, 5, 5, 5, 1, 1, 1, 1, 5, 1, 5, 1, 1, 1, 1, 3, 5, 5, 5, 0, 1, 0},
            {5, 0, 1, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 5, 1, 1, 0},
            {5, 0, 5, 0, 1, 1, 5, 1, 5, 1, 5, 3, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0},
            {1, 0, 5, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 5, 1, 1, 0, 1, 0},
            {1, 0, 1, 5, 5, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 5, 0, 5, 0, 5, 0},
            {5, 1, 5, 0, 5, 0, 5, 0, 0, 0, 5, 0, 0, 0, 0, 5, 0, 5, 1, 3, 0, 1, 0, 1, 0},
            {1, 0, 5, 0, 1, 0, 5, 0, 5, 5, 5, 5, 4, 5, 5, 5, 0, 5, 0, 1, 0, 1, 0, 1, 0},
            {3, 0, 1, 0, 1, 5, 3, 0, 5, 0, 0, 0, 0, 0, 5, 0, 0, 5, 0, 1, 0, 5, 1, 1, 0},
            {1, 0, 5, 1, 1, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 1, 0, 1, 0, 3, 0},
            {5, 0, 5, 0, 1, 0, 0, 1, 0, 0, 0, 0, 5, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0},
            {5, 1, 5, 0, 3, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 1, 1, 1, 5, 1, 0, 1, 0, 5, 0},
            {1, 0, 1, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0},
            {1, 0, 1, 5, 1, 1, 1, 1, 1, 1, 1, 1, 5, 3, 1, 1, 5, 1, 1, 1, 1, 1, 0, 1, 0},
            {1, 0, 0, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 3, 0, 0, 1, 0},
            {1, 1, 1, 1, 1, 1, 5, 1, 1, 1, 1, 5, 1, 1, 3, 5, 5, 5, 1, 1, 5, 1, 5, 1, 0},
        }
        playerPositionXInTilemap = 11
        playerPositionYInTilemap = 2  
        x = playerPositionXInTilemap * moveConstant + 7
        y = playerPositionYInTilemap * moveConstant + 7
        bgWater = love.graphics.newImage("img/background4.png")
        bgGreenPlants = love.graphics.newImage("img/midground.png")  
    else 
        tilemap = {
            {0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        }
    end
 end