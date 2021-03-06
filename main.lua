--[[
    Spamality!+lovejam alpha (c) iLiquid 2018
    arcade shooter where you spam to win
    licensed under the ISC license
]]

require 'jam/jam'
require 'jam/shooter'
require 'player'
require 'wave'

Map.tileset = ' 12340<->^|v./=\\"~\'(_)'
Map.solids = '12340<->^|v'
Map.entityset = {
    SpamalityPlayer,
    SpamalityEnemy,
    SpamalitySpawner
}

jam.states.title = {}
jam.setstate('title')

wavetext = nil
gameovertext = nil

function jam.load()
    love.graphics.setFont(jam.assets.fonts['main'])

    wavetext = love.graphics.newText(jam.assets.fonts['main'])
    gameovertext = love.graphics.newText(jam.assets.fonts['main'])
end

function jam.states.title.draw()
    jam.assets.maps['map_1']:reset()
    jam.assets.maps['map_1']:draw()
    jam.activemap = nil

    jam.assets.sprites['logo']:draw(1, 128 / 2 - 123 / 2, 48)
    if love.timer.getTime() % 1 < 0.5 then
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf('> CLICK TO BEGIN <', 0, 73, 130, 'center')
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf('> CLICK TO BEGIN <', 0, 72, 128, 'center')
    end
end

function jam.states.title.update(dt)
    if love.mouse.isDown(1) then
        jam.assets.maps['map_1']:begin()
        jam.setstate('game')
    end
end

gameover = false
function jam.states.game.draw()
    jam.assets.maps['map_1']:draw()

    if gameover then
        gameovertext:set('GAME OVER! CLICK TO RESTART')
        love.graphics.setColor(0, 0, 0)
        love.graphics.draw(gameovertext, 128 / 2 - gameovertext:getWidth() / 2 + 1, 64 + 1)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(gameovertext, 128 / 2 - gameovertext:getWidth() / 2, 64)
        if love.mouse.isDown(1) then
            wave = 1
            gametime = 0
            jam.assets.maps['map_1']:begin()
        end
    else
        wavetext:set('WAVE '..wave)
        love.graphics.draw(wavetext, 128 / 2 - wavetext:getWidth() / 2, 0)
    end
end

gametime = 0
function jam.states.game.update(dt)
    gametime = gametime + dt

    enemies = 0
    jam.activemap:eachEntity(function (entity)
        if entity.supertype == 'enemy' then enemies = enemies + 1 end
    end)

    if gametime > 2.5 and enemies <= 0 then
        gametime = 0
        wave = wave + 1
        jam.activemap:eachEntity(function (entity)
            if entity.supertype == 'spawner' then entity:nextwave() end
            if entity.supertype == 'player' then
                entity.spamality = entity.spamality + wave * 10
            end
        end)
    end

    gameover = true
    jam.activemap:eachEntity(function (entity)
        if entity.supertype == 'player' then gameover = false end
    end)
end
