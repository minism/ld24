require 'area'

local game = Context()


function game.setup()
    -- Load all assets
    assets.load()
end


function game.draw()
    console:drawLog()
end


return game
