Area = Object:extend()

local WORLD_TILESIZE = 32 / math.sqrt(2)

-- Define areas with corresponding area file
function Area:init(area_name)
    -- Set area data reference
    self.data = assets.areas[area_name]()

    -- For specific layers
    self.tilelayers = {}
end


-- Process area data and load anything necessary
function Area:load()
    -- Cache layers
    self.tilelayers.bg = self:getLayer('bg')
end


function Area:draw()
    self:drawTiles()
end


function Area:drawTiles()
    -- Clear last frame
    local spritebatch = tilehelper.spritebatch.main
    local quads = tilehelper.quads.main
    spritebatch:clear()

    -- Process tiles
    for name, layer in pairs(self.tilelayers) do
        for x=1, layer.width do
            for y=1, layer.height do
                local index = x + (y - 1) * layer.height
                local tile_id = layer.data[index]
                if tile_id and tile_id > 0 then
                    -- Add tile's quad to spritebatch, transformed to ortho projection
                    spritebatch:addq(quads[tile_id], 
                                     iso.worldQuad(x * WORLD_TILESIZE, 
                                                   y * WORLD_TILESIZE))
                end
            end
        end
    end

    -- Render spritebatch
    love.graphics.draw(spritebatch)
end


-- Return the layer object from Tiled data given name
function Area:getLayer(layername)
    for i, tilelayer in ipairs(self.data.layers) do
        if tilelayer.name == layername then
            return tilelayer
        end
    end
    return {}
end
