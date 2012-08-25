require 'area'
require 'player'

local game = Context()

game.entities = {}


function game.setup()
    -- Load everything
    assets.load()
    tilehelper.load()

    -- Setup player
    game.player = Player()
    game.addEntity(game.player)

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

    area1 = Area('test')
    area1:load()
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

            -- Draw area
            area1:draw()

            -- Draw entities
            for i, entity in ipairs(game.entities) do
                entity:draw()
            end

        love.graphics.pop()
    love.graphics.pop()

    console:drawLog()
    if config.debug then
        love.graphics.print(love.timer.getFPS(), love.graphics.getWidth() - 50, 0)
    end
end


function game:update(dt)
    -- Update player
    game.player:update(dt)

end


function game:keypressed(key, unicode)
    -- Toggle isometric mode
    if key == 'f2' then
        config.iso = not config.iso
    end
end


return game
