local assets = {}

function assets.load()
    assets.gfx = leaf.fs.loadImages('gfx', assets.loadCallback)
    -- assets.sfx = leaf.fs.loadSounds('sfx', assets.loadCallback)
    -- assets.music = leaf.fs.loadSounds('music', assets.loadCallback)
    assets.areas = leaf.fs.loadChunks('areas', assets.loadCallback)
    -- assets.shaders = leaf.fs.loadShaders('shaders', assets.loadCallback)

    -- Dont filter
    for k, img in pairs(assets.gfx) do
        img:setFilter('nearest', 'nearest')
    end

    -- assets.font = {
    --     small = love.graphics.newFont('font/font.ttf', 32),
    --     large = love.graphics.newFont('font/font.ttf', 48),
    --     huge = love.graphics.newFont('font/font.ttf', 72),
    -- }
end

function assets.loadCallback(progress, path)
    console:write("Loaded asset " .. path)
end


return assets
