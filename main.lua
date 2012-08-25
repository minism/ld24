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
-- Check if rect intersects with another rect
function rect_intersects(left1, top1, right1, bot1, left2, top2, right2, bot2)
    if left2 >= left1 and left2 <= right1 then
        if top2 >= top1 and top2 <= bot1 then
            return true
        elseif bot2 >= top1 and bot2 <= bot1 then
            return true
        end
    elseif right2 >= left1 and right2 >= right1 then
        if top2 >= top1 and top2 <= bot1 then
            return true
        elseif bot2 >= top1 and bot2 <= bot1 then
            return true
        end
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
    ui = require 'ui'

    -- Global timer that always runs
    time = Time()

    -- Start game
    app:bind()
    app:pushContext(game)
    game.setup()

    console:write("Game initialized")
end

