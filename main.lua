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
    assets = require 'assets'
    tilehelper = require 'tilehelper'
    iso = require 'iso'
    game = require 'game'

    -- Start game
    app:bind()
    app:pushContext(game)
    game.setup()

    console:write("Game initialized")
end

