require 'lib.astar.astar'

Area = leaf.Object:extend()

local WORLD_TILESIZE = 32 / math.sqrt(2)

-- Logical tile
local LogicTile = leaf.Object:extend()

function LogicTile:init(conf)
    _.extend(self, conf or {})
    assert(self.x and self.y and self.type, "Logic tile was missing property")
end


-- Define areas with corresponding area file
function Area:init(areaname)
    self.name = areaname

    -- Parse area map file
    self.data = assets.areas[areaname]()

    -- For specific layers
    self.tilelayers = {}

    -- Logical tiles
    self.logic_tiles = {}

    -- For sp init data
    self.sp_init = {}

    -- Persistent flags
    self.flags = {
        lights = false,
        used_chamber = false,
    }
end


-- Given a row, col index for a tile, return world coords
function Area.tileToWorld(row, col)
    return row * WORLD_TILESIZE, col * WORLD_TILESIZE
end

-- Given a world coord, return row, col index for a tile
function Area.worldToTile(x, y)
    return math.floor(x / WORLD_TILESIZE), math.floor(y / WORLD_TILESIZE)
end

-- Returns a logic tile at world, if exists
function Area:logicTileAtWorld(world_x, world_y)
    local tx, ty = self.worldToTile(world_x, world_y)
    return self:logicTileAt(tx, ty)
end

-- Returns a logic tile at an index, if exists
function Area:logicTileAt(row, col)
    if row >= 1 and col >= 1 and row <= self.data.width and col <= self.data.height then
        for i, tile in ipairs(self.logic_tiles) do
            if tile.x == row and tile.y == col then
                return tile
            end
        end
    end
    return nil
end


-- Determins if floor is at a world coord
function Area:floorAtWorld(world_x, world_y)
    local tx, ty = self.worldToTile(world_x, world_y)
    return self:floorAt(tx, ty)
end

-- Determines if floor is at an index
function Area:floorAt(row, col)
    if row < 1 or col < 1 or row > self.data.width or col > self.data.height then
        return false
    end
    local index = row + (col - 1) * self.tilelayers.floor.height
    return self.tilelayers.floor.data[index] > 0
end


-- Get the world position of a conneciton tile based on name
function Area:getConnectionWorldPosition(areaname)
    for i, tile in ipairs(self.logic_tiles) do
        if tile.type == 'connection' and tile.area == areaname then
            local wx, wy = self.tileToWorld(tile.x, tile.y)
            return wx + WORLD_TILESIZE / 2, wy + WORLD_TILESIZE / 2
        end
    end
    return nil, nil
end


-- Process area data and load anything necessary
function Area:load()
    -- Cache floor and special layers
    self.tilelayers.floor = self:getLayer('floor')
    self.tilelayers.sp = self:getLayer('sp')
    assert(self.tilelayers.floor.width, "No floor layer")

    -- Process map SP layer
    self.sp_init = {}
    local layer = self.tilelayers.sp
    if layer then
        for x=1, layer.width do
            for y=1, layer.height do
                local index = x + (y - 1) * layer.height
                local tile_id = layer.data[index]
                local wx, wy = self.tileToWorld(x, y)
                table.insert(self.sp_init, {
                    id = tile_id,
                    x = wx + WORLD_TILESIZE / 2,
                    y = wy + WORLD_TILESIZE / 2,
                })

                -- HACK: add chamber as a logic tile
                if tile_id == 57 then
                    local tile = LogicTile {
                        x = x,
                        y = y,
                        type = 'chamber',
                    }
                    table.insert(self.logic_tiles, tile)
                end
            end
        end
    end

    -- Process connections in map
    local connection_layer = self:getLayer('connections')
    if connection_layer then
        for i, connection in ipairs(connection_layer.objects) do
            local tile = LogicTile {
                x = math.floor(connection.x / 16),
                y = math.floor(connection.y / 16),
                type = 'connection',
                area = connection.name,
            }
            table.insert(self.logic_tiles, tile)
        end
    end

    -- Setup pathfinder
    self.astar = AStar(self)
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
        if layer.name ~= 'sp' and layer.type == 'tilelayer' then
            for x=1, layer.width do
                for y=1, layer.height do
                    local index = x + (y - 1) * layer.height
                    local tile_id = layer.data[index]
                    if tile_id and tile_id > 0 then
                        -- Add tile's quad to spritebatch, transformed to ortho projection
                        spritebatch:addq(quads[tile_id], iso.toOrtho(self.tileToWorld(x - 1.5, y - 0.5)))
                    end
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



-- A* Methods

-- Given x, y in world coordinates, find an appropriate velocity vector
-- to the player based on A*
function Area:findPathVector(world_x, world_y, cost)
    local src = vector.new(self.worldToTile(world_x, world_y))
    local dst = vector.new(self.worldToTile(game.player.x, game.player.y))
    local path = self.astar:findPath(src, dst)
    if path then
        local first_node = path:getNodes()[1]
        if first_node then
            local tile_worldx, tile_worldy = self.tileToWorld(first_node.location.x, first_node.location.y)
            tile_worldx = tile_worldx + WORLD_TILESIZE / 2
            tile_worldy = tile_worldy + WORLD_TILESIZE / 2
            return tile_worldx - world_x, tile_worldy - world_y, path:getTotalMoveCost()
        end
    end
    return nil
end


function Area:getNode(location)
  -- Here you make sure the requested node is valid (i.e. on the map, not blocked)
  -- if the location is not valid, return nil, otherwise return a new Node object
  if self:floorAt(location.x, location.y) then
    return Node(location, 1, location.y * self.data.height + location.x)
  end
  return nil
end

function Area:locationsAreEqual(a, b)
  -- Here you check to see if two locations (not nodes) are equivalent
  -- If you are using a vector for a location you may be able to simply
  -- return a == b
  -- however, if your location is represented some other way, you can handle 
  -- it correctly here without having to modufy the AStar class
  return a.x == b.x and a.y == b.y
end

function Area:getAdjacentNodes(curnode, dest)
  -- Given a node, return a table containing all adjacent nodes
  -- The code here works for a 2d tile-based game but could be modified
  -- for other types of node graphs
  local result = {}
  local cl = curnode.location
  local dl = dest

  local n_up, n_left, n_down, n_right = nil, nil, nil, nil
  
  n = self:_handleNode(cl.x + 1, cl.y, curnode, dl.x, dl.y)
  if n then
    n_right = n
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x, cl.y + 1, curnode, dl.x, dl.y)
  if n then
    n_down = n
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x - 1, cl.y, curnode, dl.x, dl.y)
  if n then
    n_left = n
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x, cl.y - 1, curnode, dl.x, dl.y)
  if n then
    n_up = n
    table.insert(result, n)
  end
  
  -- Diagonals
  if n_right and n_down then
      n = self:_handleNode(cl.x + 1, cl.y + 1, curnode, dl.x, dl.y)
      if n then
        table.insert(result, n)
      end
  end

  if n_left and n_up then
      n = self:_handleNode(cl.x - 1, cl.y - 1, curnode, dl.x, dl.y)
      if n then
        table.insert(result, n)
      end
  end

  if n_left and n_down then
      n = self:_handleNode(cl.x - 1, cl.y + 1, curnode, dl.x, dl.y)
      if n then
        table.insert(result, n)
      end
  end

  if n_right and n_up then
      n = self:_handleNode(cl.x + 1, cl.y - 1, curnode, dl.x, dl.y)
      if n then
        table.insert(result, n)
      end
  end
  
  return result
end

function Area:_handleNode(x, y, fromnode, destx, desty)
  -- Fetch a Node for the given location and set its parameters
  local n = self:getNode(vector.new(x, y))

  if n ~= nil then
    local dx = math.max(x, destx) - math.min(x, destx)
    local dy = math.max(y, desty) - math.min(y, desty)
    local emCost = dx + dy
    
    n.mCost = n.mCost + fromnode.mCost
    n.score = n.mCost + emCost
    n.parent = fromnode
    
    return n
  end
  
  return nil
end