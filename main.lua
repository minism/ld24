require 'math'
require 'os'
tween = require 'lib.tween'
inspect = require 'lib.inspect'
_ = require 'lib.underscore'

-- Import everything from leaf directly
require 'leaf'
for k, v in pairs(leaf) do
    _G[k] = v
end


-- Patch function
-- Check if rect contains an object or a point
function rect_contains(left, top, right, bottom, x, y)
    if  x >= left and
        x <= right and
        y >= top and
        y <= bottom then 
        return true     
    end
    return false
end

function love.load()
    -- Seed randomness
    math.randomseed(os.time()); math.random()

    -- Register global singletons
    console = Console()
    app = App()
    color = require 'colors'
    assets = require 'assets'
    tilehelper = require 'tilehelper'
    iso = require 'iso'
    keys = require 'keys'
    game = require 'game'

    -- Global timer that always runs
    time = Time()

    -- Start game
    app:bind()
    app:pushContext(game)
    game.setup()

    console:write("Game initialized")
end

