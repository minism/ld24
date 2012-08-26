local tilehelper = {
    quads = {},
    spritebatch = {},
}

local MAX_SPRITES = 1000

function tilehelper.load()
    for name, image in pairs(assets.tilesets) do
        -- Build quads
        tilehelper.quads[name] = build_quads(image, 32, 32, 1, 1)
        console:write("Built tile quads for " .. name)

        -- Build spritebatch
        tilehelper.spritebatch[name] = love.graphics.newSpriteBatch(image)
    end
end

return tilehelper
