require 'sprite'

local assets = {}

function assets.load()
    assets.tilesets = leaf.fs.loadImages('tilesets', assets.loadCallback)
    assets.gfx = leaf.fs.loadImages('gfx', assets.loadCallback)
    assets.areas = leaf.fs.loadChunks('areas', assets.loadCallback)
    assets.sfx = leaf.fs.loadSounds('sfx', assets.loadCallback)
    assets.music = {
        music = love.audio.newSource('music/music.mp3', 'streaming')
    }

    -- Dont filter images
    for k, img in pairs(assets.tilesets) do
        img:setFilter('nearest', 'nearest')
    end
    for k, img in pairs(assets.gfx) do
        img:setFilter('nearest', 'nearest')
    end

    assets.font = {
        ui = love.graphics.newFont('font/font.ttf', 18),
        window = love.graphics.newFont('font/font.ttf', 24),
        large = love.graphics.newFont('font/font.ttf', 48),
        huge = love.graphics.newFont('font/font.ttf', 72),
    }
end

function assets.loadCallback(progress, path)
    console:write("Loaded asset " .. path)
end


return assets
