require 'area'
require 'player'

local game = {}
game.entities = {}


function game.setup()
    -- Load everything
    assets.load()
    tilehelper.load()

    -- Setup player
    game.player = Player()
    game.addEntity(game.player)

    -- Setup active area
    game.area = nil

    -- Setup graphics
    game.blindnessStencil = love.graphics.newStencil(function() 
        love.graphics.circle("fill", game.player.x, game.player.y, game.player.stats.vision)
    end)

    -- Setup camera to track player
    game.camera = Camera {
        scale = config.scale,
        track_func = function()
            if config.iso then
                return iso.toIso(game.player.x, game.player.y)
            end
            return game.player.x, game.player.y
        end,
    }

    -- Test
    game.loadArea('test')
end

function game.loadArea(areaname)
    -- Load area data
    game.area = Area(areaname)
    game.area:load()

    -- React to any sp tile init data
    if game.area.sp_init.player then
        game.player.x = game.area.sp_init.player.x
        game.player.y = game.area.sp_init.player.y
    end
end

function game.addEntity(e)
    table.insert(game.entities, e)
end


function game:draw()
    -- Draw in camera projection
    love.graphics.push()
    game.camera:applyMatrix()

        -- Draw in isometric projection
        love.graphics.push()
        if config.iso == true then iso.applyMatrix() end

            -- Draw blindness
            if config.blind then love.graphics.setStencil(game.blindnessStencil) end

            -- Draw area
            game.area:draw()

            -- Draw entities
            for i, entity in ipairs(game.entities) do
                entity:draw()
            end

            -- Draw blindness
            if config.blind then game:drawBlindness() end

        love.graphics.pop()
    love.graphics.pop()

    -- Clear stencil
    love.graphics.setStencil()

    console:drawLog()
    if config.debug then
        love.graphics.print(love.timer.getFPS(), love.graphics.getWidth() - 50, 0)
    end
end

-- Draw blindness circles around a point
function game:drawBlindness()
    local x, y, rad = game.player.x, game.player.y, game.player.stats.vision
    color.black(192)
    love.graphics.circle('fill', x, y, rad, rad)
    love.graphics.setBlendMode('multiplicative')
    color.white(150)
    for i=1,2 do
        love.graphics.circle('fill', x, y, rad * i / 3)
        love.graphics.circle('fill', x, y, rad * i / 3)
    end
    love.graphics.setBlendMode('alpha')
    color.white()
end


function game:update(dt)
    -- Update global time manager
    time:update(dt)

    -- Update player
    game.player:update(dt)

end


function game:keypressed(key, unicode)
    -- Toggle isometric mode
    if key == 'f2' then
        config.iso = not config.iso
    end
    -- Toggle collision 
    if key == 'f3' then
        config.collision = not config.collision
    end
    -- Toggle blindness
    if key == 'f4' then
        config.blind = not config.blind
    end
end

return game
