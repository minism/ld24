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


function love.load()
    -- Seed randomness
    math.randomseed(os.time()); math.random()

    -- Register global singletons
    console = Console()
    app = App()
    color = require 'colors'

    -- Start game
    app:bind()
    local game = require 'game'
    app:pushContext(game)

    console:write("Game initialized")
end

