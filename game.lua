require 'area'
require 'player'
require 'enemy'
require 'item'
require 'window'
require 'objects'

local game = {}


function game.setup()
    -- Load everything
    assets.load()
    tilehelper.load()

    -- Setup player
    game.player = Player()

    -- Setup active area
    game.area = nil
    game.doors = {}

    -- Setup graphics
    game.blindnessStencil = love.graphics.newStencil(function() 
        love.graphics.circle("fill", game.player.x, game.player.y, game.player:stat('vision'))
    end)

    -- Setup camera to track player
    game.camera = Camera {
        scale = config.scale,
        track_func = function()
            if config.iso then
                return iso.toIso(game.player.x, game.player.y)
            end
            return game.player.x, game.player.y
        end,
    }

    -- Persistent flags
    game.flags = {
        first_chamber = true,
    }

    -- Game state
    game.state = {
        subjects = 100,
        modules = 0,
    }

    -- Test
    game.loadArea('base')
end


-- Player entered a tile, do anything necessary
function game.checkPlayerTileEvent(px, py)
    -- Check for area logic tiles
    local tile = game.area:logicTileAtWorld(px, py)
    if tile then
        if tile.type == "connection" then 
            game.gotoArea(tile.area)
        elseif tile.type == "chamber" then
            game.useChamber()
        end
    end
end

function game.checkPlayerPositionEvent(px, py)
    -- Check for door
    for i, door in ipairs(game.doors) do
        local a,b,c,d = door:getCollisionRect()
        a = a - Door.range
        b = b - Door.range
        c = c + Door.range
        d = d + Door.range
        if rect_contains(a,b,c,d,px,py) then
            door.sprite.reverse = false
        else
            door.sprite.reverse = true
        end
    end
end


function game.processSpecialTile(data)
    local id, x, y = data.id, data.x, data.y
    local handlers = {
        [63] = function()
            game.player.x = x
            game.player.y = y
        end,

        [62] = function()
            game.addEntity(Guard { x=x, y=y })
        end,

        [61] = function()
            game.addEntity(Scientist { x=x, y=y })
        end,

        [58] = function()
            local door = Door {x=x, y=y}
            game.addEntity(door)
            table.insert(game.doors, door)
        end,

        [59] = function()
            local door = Door {x=x, y=y, left=false}
            game.addEntity(door)
            table.insert(game.doors, door)
        end,

    }
    if handlers[id] then handlers[id]() end
end


function game.destroyEntities()
    if game.entities then
        for i, entity in ipairs(game.entities) do
            entitiy:destroy()
        end
    end
    if game._entity_queue then
        for i, entity in ipairs(game._entity_queue) do
            entitiy:destroy()
        end
    end
end


function game.loadArea(areaname)
    local lastarea_name = nil
    if game.area and game.area.name then
        lastarea_name = game.area.name
    end

    -- Dump previous data
    game.doors = {}
    game.destroyEntities()
    game.entities = {}
    game._entity_queue = {}

    -- Load area data
    game.area = Area(areaname)
    game.area:load()
    
    -- Prepare the render index
    game._render_index = {}
    for i=1, game.area.data.width * game.area.data.height do
        game._render_index[i] = {}
    end

    -- React to any sp tile init data
    for i, spdata in ipairs(game.area.sp_init) do game.processSpecialTile(spdata) end

    -- Position player based on matching connecting tile, if exists
    if lastarea_name then
        local x, y = game.area:getConnectionWorldPosition(lastarea_name)
        if x and y then
            game.player.x = x
            game.player.y = y
        end
    end
end


-- Go to an area from a connecting tile
function game.gotoArea(areaname)
    game.loadArea(areaname)
end


-- Try to use a chamber
function game.useChamber()
    -- Check if already used in this area
    if not game.area.flags.used_chamber then
        -- Show chamber window
        local chamber_win = ChamberWindow(function(success)
            if success == true then
                game.area.flags.used_chamber = true
            end
        end)
        app:pushContext(chamber_win)

        -- Show on first usage in game
        if game.flags.first_chamber then
            game.flags.first_chamber = false
            game.showWindow("Hyperincubator explanation...")
        end
    end
end


-- Display a modal dialog
function game.showWindow(text, callback)
    local win = Window(text, callback)
    app:pushContext(win)
end


function game.dropModules(x, y)
    local nmodules = math.random(1, 3)
    for i=1, nmodules do
        local theta = math.random() * math.pi * 2
        local drop_velx, drop_vely = vector.rotate(1, 0, theta)
        local mod = Module {
            x = x,
            y = y,
            velx = drop_velx,
            vely = drop_vely,
        }
        game.addEntity(mod)
    end
end

function game.addEntity(e)
    table.insert(game._entity_queue, e)
end


function game.updateRenderIndex(index, entity)
    if game._render_index[index] then
        table.insert(game._render_index[index], entity)
    end
end

function game.clearRenderIndex()
    for i, table in ipairs(game._render_index) do
        for k,v in pairs(table) do table[k]=nil end
    end
end



function game.drawScene()
    -- Clear render index from last frame
    game.clearRenderIndex()

    -- Index all entities by position
    for i, entity in ipairs(game.entities) do
        local tile_index = game.area:getTileIndexFromWorld(entity.x, entity.y)
        game.updateRenderIndex(tile_index, entity)
    end

    -- Index player
    local tile_index = game.area:getTileIndexFromWorld(game.player.x, game.player.y)
    game.updateRenderIndex(tile_index, game.player)

    local quads = tilehelper.quads.main
    local tileset_image = assets.tilesets.main

    -- Draw everything on a tile one at a time
    for x=1, game.area.data.width do
        for y=1, game.area.data.height do
            -- Process tiles onto sprite batch
            for i, layer in ipairs(game.area.data.layers) do
                -- Dont draw special tiles
                if layer.name ~= 'sp' and layer.type == 'tilelayer' then
                    local index = game.area:getTileIndex(x, y)
                    local tile_id = layer.data[index]
                    if tile_id and tile_id > 0 then
                        -- Add tile's quad to spritebatch, transformed to ortho projection
                        -- spritebatch:addq(quads[tile_id], iso.toOrtho(Area.tileToWorld(x - 1.5, y - 0.5)))
                        love.graphics.drawq(tileset_image, quads[tile_id], iso.toOrtho(Area.tileToWorld(x - 1.5, y - 0.5)))
                    end

                    -- Draw any entities in this index
                    for ei, entity in ipairs(game._render_index[index]) do
                        entity:draw()
                    end
                end
            end
        end
    end
end


function game:draw()
    -- Draw in camera projection
    love.graphics.push()
    game.camera:applyMatrix()

        -- Draw in isometric projection
        love.graphics.push()
        if config.iso == true then iso.applyMatrix() end

            -- Draw blindness
            if config.blind then love.graphics.setStencil(game.blindnessStencil) end

            -- Draw area and entities
            game.drawScene()

            -- Draw blindness
            if config.blind then game:drawBlindness() end

            if DBR then
                color.debug()
                love.graphics.rectangle("fill", unpack(DBR))
            end

        love.graphics.pop()
    love.graphics.pop()

    -- Clear stencil
    love.graphics.setStencil()

    -- Draw UI
    ui.draw()

    -- Draw debug stuff
    if config.debug and config.show_console then
        console:drawLog()
        love.graphics.print(love.timer.getFPS(), love.graphics.getWidth() - 50, 0)
    end
end

-- Draw blindness circles around a point
function game:drawBlindness()
    local x, y, rad = game.player.x, game.player.y, game.player:stat('vision')
    color.black(192)
    love.graphics.circle('fill', x, y, rad, rad)
    love.graphics.setBlendMode('multiplicative')
    color.white(150)
    for i=1,2 do
        love.graphics.circle('fill', x, y, rad * i / 3)
        love.graphics.circle('fill', x, y, rad * i / 3)
    end
    love.graphics.setBlendMode('alpha')
    color.white()
end

function game.flushEntityQueue()
    for i, entity in ipairs(game._entity_queue) do
        table.insert(game.entities, entity)
        game._entity_queue[i] = nil
    end
end

function game:update(dt)
    -- Update global time manager
    time:update(dt)

    -- Update player
    game.player:update(dt)

    -- Add pending entities
    game.flushEntityQueue()

    -- Update entities
    remove_if(game.entities, function(entity)
        if entity ~= nil then 
            entity:update(dt)

            -- Check for collisions
            if entity.hit == "p_attack" and not entity.dead then
                for i, entity2 in ipairs(game.entities) do
                    if entity2.hit == "enemy" then
                        l, t, r, b = entity2:getCollisionRect()
                        if rect_contains(l, t, r, b, entity.x, entity.y) then
                            entity2:getHit(entity)
                            entity.dead = true
                        end
                    end
                end
            end

            -- Check player collisions

            -- Module pickup
            if entity.hit == "module" and not entity.dead then
                local a,b,c,d = entity:getCollisionRect()
                local e,f,g,h = game.player:getCollisionRect()
                if rect_intersects(a,b,c,d,e,f,g,h) then
                    entity:die()
                    game.state.modules = game.state.modules + 1
                end
            end

            return entity.dead == true
        end
        return false
    end)

end


function game:keypressed(key, unicode)
    -- Handle debug keys
    if config.debug then
        -- Toggle isometric mode
        if key == 'f2' then
            config.iso = not config.iso
        end
        -- Toggle collision 
        if key == 'f3' then
            config.collision = not config.collision
        end
        -- Toggle blindness
        if key == 'f4' then
            config.blind = not config.blind
        end
        -- Toggle blindness
        if key == 'f5' then
            config.show_console = not config.show_console
        end
        -- Reset game
        if key == 'f6' then
            game.loadArea('base')
        end
    end
end

return game
