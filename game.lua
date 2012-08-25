require 'area'

local game = Context()


function game.setup()
    -- Load everything
    assets.load()
    tilehelper.load()

    -- Setup camera
    game.camera = Camera()

    area1 = Area('test')
    area1:load()
end


function game.draw()
    -- Draw in camera projection
    love.graphics.push()
    game.camera:applyMatrix()

        -- Draw in isometric projection
        love.graphics.push()
        iso.applyMatrix()

            area1:draw()

        love.graphics.pop()
    love.graphics.pop()



    console:drawLog()
    if config.debug then
        love.graphics.print(love.timer.getFPS(), love.graphics.getWidth() - 50, 0)
    end
end


return game
