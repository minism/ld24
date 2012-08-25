Area = Object:extend()

local WORLD_TILESIZE = 32 / math.sqrt(2)

-- Define areas with corresponding area file
function Area:init(area_name)
    -- Parse area map file
    self.data = assets.areas[area_name]()

    -- For specific layers
    self.tilelayers = {}

    -- For sp init data
    self.sp_init = {}
end


-- Given a row, col index for a tile, return world coords
function tileToWorld(row, col)
    return row * WORLD_TILESIZE, col * WORLD_TILESIZE
end



-- Process area data and load anything necessary
function Area:load()
    -- Cache floor and special layers
    self.tilelayers.floor = self:getLayer('floor')
    self.tilelayers.sp = self:getLayer('sp')
    assert(self.tilelayers.floor.width, "No floor layer")

    -- Process special tiles
    local layer = self.tilelayers.sp
    if layer then
        for x=1, layer.width do
            for y=1, layer.height do
                local index = x + (y - 1) * layer.height
                local tile_id = layer.data[index]
                if tile_id == tilehelper.special.player then
                    self.sp_init.player = vector.new(tileToWorld(x, y))
                end
            end
        end
    end

end


function Area:draw()
    self:drawTiles()
end


function Area:drawTiles()
    local spritebatch = tilehelper.spritebatch.main
    local quads = tilehelper.quads.main

    -- Clear spritebatch from last frame
    spritebatch:clear()

    -- Process tiles onto sprite batch
    for i, layer in ipairs(self.data.layers) do
        -- Dont draw special tiles
        if layer.name == 'sp' then break end

        for x=1, layer.width do
            for y=1, layer.height do
                local index = x + (y - 1) * layer.height
                local tile_id = layer.data[index]
                if tile_id and tile_id > 0 then
                    -- Add tile's quad to spritebatch, transformed to ortho projection
                    spritebatch:addq(quads[tile_id], iso.toOrtho(tileToWorld(x - 1.5, y - 0.5)))
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
