

BASEDIR = love.filesystem.getRealDirectory("/modules"):match("(.-)[^%.]+$")
BASEDIR = string.sub(BASEDIR, 1, string.len(BASEDIR)-1)
local myPath = BASEDIR..'/modules/?.lua;'..BASEDIR..'/data/?.lua'
local myPath2 = 'modules/?.lua;/data/?.lua'

package.path = myPath
love.filesystem.setRequirePath( myPath2 )


-- virtual resolution handling library
push = require 'push'
class = require 'class'
require 'Bird'
require 'Pipe'

require 'PipePair'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('images/background.png')
local backgroundScroll = 0
local ground = love.graphics.newImage('images/ground.png')
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

-- point at which we should loop our background back to X 0
local BACKGROUND_LOOPING_POINT = 413

local bird = Bird()
local pipes = {}
local pipePairs = {}

local spawnTimer = 0

local lastY = -PIPE_HEIGHT + math.random(80) + 20

local scrolling = true

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Fifty Bird')
    math.randomseed(os.time())
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true         
    })

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true --[[ popular com key ]]
    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key) --[[  on the last frame, the key was pressed? ]]
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end   
end

function love.update(dt) 
    if scrolling then
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) 
            % BACKGROUND_LOOPING_POINT

        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
            % VIRTUAL_WIDTH

        spawnTimer = spawnTimer + dt

        if spawnTimer > 2 then
            local y = math.max(-PIPE_HEIGHT + 10,
                math.min(lastY + math.random(-20,20), VIRTUAL_HEIGHT -90 - PIPE_HEIGHT))
                lastY = y

            table.insert(pipePairs, PipePair(y))
            spawnTimer = 0
        end

        bird:update(dt)
        -- for every pipe in the scene...
        for k, pair in pairs(pipePairs) do
            pair:update(dt)

            for l, pipe in pairs(pair.pipes) do
                if bird:collides(pipe) then
                    scrolling = false
                end
            end

            if pair.x < -PIPE_WIDTH then
                pair.remove = true
            end

        end

        for k, pipe in pairs(pipes) do
    
            if pair.remove then
                table.remove(pipePairs, k)
            end
        end
    end   
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    -- draw the background starting at top left (0, 0)
    love.graphics.draw(background, -backgroundScroll, 0)
    for k, pipe in pairs(pipePairs) do
        pipe:render()
    end
    love.graphics.draw(ground, -groundScroll , VIRTUAL_HEIGHT - 16)  
    bird:render()

    push:finish()
end