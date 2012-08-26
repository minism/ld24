require 'area'
require 'player'
require 'enemy'
require 'item'
require 'window'
require 'objects'

local game = {}

local AREA_FADE_TIME = 0.15
local INIT_FADE_TIME = 3

local CHAMBER_MODULES = 10

function game.setup()
    -- Load everything
    assets.load()
    tilehelper.load()

    -- Setup player
    game.player = Player()
    game.player.state.health = game.player:stat('vitality')

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
        first_lights = true,
        first_subject = true,
        got_blaster = false,
    }

    -- Game state
    local tx, ty = Area.tileToWorld(7, 14)
    game.state = {
        subjects = 25,
        modules = 0,
        save = {
            area = config.start_area,
            x = tx,
            y = ty,
        }
    }

    -- Extra timers
    game.timers = {
        fade_screen = 0,
        init_fade = INIT_FADE_TIME,  --start fading in
        enemy_collide = 0,
    }
    game.pending_x, game.pending_y = nil, nil
    game.pending_load = nil

    -- Screen overlay
    game.overlay = {0, 0, 0, 255}

    -- Start dialog

    game.showWindow("(MOVE AROUND WITH: W, A, S, D)  \n\n(ATTACK WITH: I, J, K, L)", function()
        -- Start music
        if config.music then
            assets.music.music:setLooping(true)
            assets.music.music:setVolume(0.6)
            assets.music.music:play()
        end
    end)

    game.showWindow "LOOKING AROUND YOU CAN SEE SEVERAL OTHER TEST SUBJECTS IN THE ROOM.  \n\nYOU BEGIN TO FILL WITH RAGE."
    game.showWindow "YOU AWAKE IN THE SHATTERED REMAINS OF A HOLDING CELL.  \n\nFOR SOME TIME NOW YOU HAVE BEEN HELD CAPTIVE HERE AT HumanTECH AGAINST YOUR WILL.  \n\nYOUR BODY HAS BEEN PROVIDING A RESEARCH SUBJECT FOR GENETIC MUTATION DESIGN."


    -- Load first area
    game.loadArea(config.start_area)
end

-- Check for major changes
function game.checkMajorState()
    -- Player dead?
    if game.player.state.health <= 0 then
        game.respawn()
    end

    -- Player won?
    if game.state.subjects <= 0 then
        game.showWindow("CONGRATULATIONS, YOU FREED ALL THE SURVIVORS! ", function()
            love.event.quit()
        end)
    end
end

function game.respawn()
    game.player.state.health = game.player:stat('vitality')
    game.gotoArea(game.state.save.area, game.state.save.x, game.state.save.y)
end

function game.toggleLights()
    -- Show on first usage in game
    if game.flags.first_lights then
        game.flags.first_lights = false
        game.showWindow("IF FUNCTIONAL, THESE CONSOLES CAN BE USED TO CONTROL THE LIGHT OF A ROOM")
    end
    game.area.flags.lights = not game.area.flags.lights 
    audio.play('lights')
end

function game.releaseSubject(subject)
    -- Show on first usage in game
    if game.flags.first_subject then
        game.flags.first_subject = false
        game.showWindow("SUBJECT:  Ahh... Thank you!  I have been floating in this damn container for years.  \n\nBy my last count there were 25 of us subjects in total.  We should explore this hellish complex in search of our brothers.")
    end
    if subject.state then
        game.state.subjects = game.state.subjects - 1
        subject.state = false
        audio.play('thanks')
    end
end


function game.checkPlayerWallEvent(px, py)
    local tx, ty = Area.worldToTile(px, py)
    if not game.wall_consume then
        game.wall_consume = true
        for i, entity in ipairs(game.entities) do
            local x, y = Area.worldToTile(entity.x, entity.y)
            if x + entity.xofs == tx and y + entity.yofs == ty then
                if isinstance(entity, Light) then
                    game.toggleLights()
                end
            end
        end
    end
end



-- Player entered a tile, do anything necessary
function game.checkPlayerTileEvent(px, py)
    local tx, ty = Area.worldToTile(px, py)
    game.wall_consume = false

    -- Check for area logic tiles
    local tile = game.area:logicTileAtWorld(px, py)
    if tile then
        if tile.type == "connection" then 
            game.gotoArea(tile.area)
        end
    end

    -- Check for chamber
    if game.area.chamber then
        local x, y = Area.worldToTile(game.area.chamber.x, game.area.chamber.y)
        if x - 1 == tx and y == ty then
            game.useChamber()
        end
    end

    for i, entity in ipairs(game.entities) do
        local x, y = Area.worldToTile(entity.x, entity.y)
        if x + entity.xofs == tx and y + entity.yofs == ty then
            if isinstance(entity, Subject) then
                game.releaseSubject(entity)
            elseif isinstance(entity, Blaster) then
                game.showWindow("YOU FOUND A BLASTER!  YOU CAN SWITCH WEAPONS AT ANY TIME WITH [TAB]")
                entity:die()
                table.insert(game.player.state.weapons, Bullet)
                game.player.state.weapon = Bullet
            end
        end
    end

end

function game.checkPlayerPositionEvent(px, py)
    -- Check for door
    for i, door in ipairs(game.doors) do
        local a,b,c,d = door:getCollisionRect()
        a = a - Door.range / 2
        b = b - Door.range / 2
        c = c + Door.range
        d = d + Door.range
        local last = door.sprite.reverse
        if rect_contains(a,b,c,d,px,py) then
            door.sprite.reverse = false
        else
            door.sprite.reverse = true
        end
        if door.sprite.reverse ~= last then
            audio.play('door')
        end
    end
end


function game.processSpecialTile(data)
    local id, x, y = data.id, data.x, data.y
    local handlers = {
        [63] = function()
            if game.area.name == 'start' then
                game.player.x = x
                game.player.y = y
            end
        end,

        [62] = function()
            game.addEntity(Guard { x=x, y=y })
        end,

        [61] = function()
            game.addEntity(Scientist { x=x, y=y })
        end,

        [60] = function()
            game.addEntity(Subject { x=x, y=y})
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

        [57] = function()
            game.area.chamber = Chamber {x = x, y = y, used = game.area.flags.used_chamber}
            game.addEntity(game.area.chamber)
        end,

        [56] = function()
            if not game.flags.got_blaster then
                game.addEntity(Blaster { x=x, y=y })
                game.flags.got_blaster = true
            end
        end,


        [49] = function()
            game.addEntity(Light { x=x, y=y})
        end,

    }
    if handlers[id] then handlers[id]() end
end


function game.destroyEntities()
    if game.entities then
        for i, entity in ipairs(game.entities) do
            if entity then entity:destroy() end
        end
    end
    if game._entity_queue then
        for i, entity in ipairs(game._entity_queue) do
            if entity then entity:destroy() end
        end
    end
end


function game.saveAreaState()
    -- Freeze entities
    game.area.save_state.entities = {}
    for i, entity in ipairs(game.entities) do
        table.insert(game.area.save_state.entities, entity)
    end
    game.area.save_state.doors = {}
    for i, door in ipairs(game.doors) do
        table.insert(game.area.save_state.doors, door)
    end
end

function game.restoreAreaState()
    -- Restore entities
    if game.area.save_state.entities then
        for i, entity in ipairs(game.area.save_state.entities) do
            game.addEntity(entity)
        end
    end
    if game.area.save_state.doors then
        for i, door in ipairs(game.area.save_state.doors) do
            table.insert(game.doors, door)
        end
    end
end


function game.loadArea(areaname, force_x, force_y)
    local lastarea_name = nil
    if game.area and game.area.name then
        lastarea_name = game.area.name
    end

    -- Dump previous data
    if game.area then game.saveAreaState() end
    game.doors = {}
    game.destroyEntities()
    game.entities = {}
    game._entity_queue = {}


    -- Load area data
    game.area = area_manager.get(areaname)
    game.area:load()
    
    -- Restore area state, if there was any
    game.restoreAreaState()

    -- Prepare the render index
    game._render_index = {}
    for i=1, game.area.data.width * game.area.data.height do
        game._render_index[i] = {}
    end

    -- Position player based on matching connecting tile, if exists
    local x, y = game.area:getConnectionWorldPosition(lastarea_name)
    if x and y then
        game.player.x = x
        game.player.y = y
    end

    -- React to any sp tile init data
    if game.area.init then
        for i, spdata in ipairs(game.area.sp_init) do game.processSpecialTile(spdata) end
        game.area.init = false
    end

    -- Forcibly position player
    if force_x and force_y then
        game.player.x, game.player.y = force_x, force_y
    end
end


-- Go to an area from a connecting tile
function game.gotoArea(areaname, x, y)
    audio.play('area')
    game.pending_load = areaname
    game.pending_x, game.pending_y = x, y
    game.timers.fade_screen = AREA_FADE_TIME
end


-- Handle timer events
function game.handleTimers()
    if game.timers.fade_screen > 0 then
        local alpha = math.min(game.timers.fade_screen / AREA_FADE_TIME * 255, 255)
        if game.pending_load then alpha = 1.0 - alpha end
        game.overlay[4] = alpha
    elseif game.pending_load then
        game.loadArea(game.pending_load, game.pending_x, game.pending_y)
        game.pending_load = nil
        game.timers.fade_screen = AREA_FADE_TIME
    end

    if game.timers.init_fade > 0 then
        local alpha = math.min(game.timers.init_fade / INIT_FADE_TIME * 255, 255)
        game.overlay[4] = alpha
    end
end




-- Try to use a chamber
function game.useChamber()
    -- Check if already used in this area
    if not game.area.flags.used_chamber then

        -- Check if enough modules
        if game.state.modules >= CHAMBER_MODULES then

            -- PLay sound
            audio.play('chamber')

            -- Show chamber window
            local chamber_win = ChamberWindow(function(success)
                if success == true then
                    -- consume modules
                    game.state.modules = game.state.modules - CHAMBER_MODULES

                    -- Restore health
                    game.player.state.health = game.player:stat('vitality')

                    -- Save for death
                    game.state.save.area = game.area.name
                    game.state.save.x = game.area.chamber.x
                    game.state.save.y = game.area.chamber.y

                    -- Mark as used
                    game.area.chamber.used = true
                    game.area.flags.used_chamber = true
                end
            end)
            app:pushContext(chamber_win)
        else
            -- TODO: Error sound
            game.showWindow("ERROR: THIS INCUBATION CHAMBER REQUIRES 10 DNA MODULES TO USE.")
        end
    end


    -- Show on first usage in game
    if game.flags.first_chamber then
        game.flags.first_chamber = false
        game.showWindow("(USING A HYPERINCUBATOR WILL STORE YOUR DNA.  IF YOUR BODY IS LOST, YOU CAN BE RECALLED HERE.)")
        game.showWindow("THIS IS A HYPERINCUBATION POD, THE MAGNUM OPUS OF HumanTECH.  \n\nTHIS ULTRA ADVANCED MACHINE CAN MAKE A COPY OF YOUR DNA, PRODUCE OFFSPRING AND RAPIDLY ACCELERATE THEIR GROWTH IN A MATTER OF NANOSECONDS.  \n\nIT IS KNOWN, HOWEVER, TO AMPLIFY NATURAL GENETIC MUTATIONS.  ALSO, YOUR OLD BODY WILL BE DISCARDED.")
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

    -- Draw floor first
    local spritebatch = tilehelper.spritebatch.main
    spritebatch:clear()
    local floor = game.area:getLayer('floor')
    love.graphics.setColor(255, 255, 255)
    for x=1, game.area.data.width do
        for y=1, game.area.data.height do
            local index = game.area:getTileIndex(x, y)
            local tile_id = floor.data[index]
            if tile_id and tile_id > 0 then
                -- Add tile's quad to spritebatch, transformed to ortho projection
                spritebatch:addq(quads[tile_id], iso.toOrtho(Area.tileToWorld(x - 1.5, y - 0.5)))
            end
        end
    end
    love.graphics.draw(spritebatch)

    -- Draw everything on a tile one at a time
    for x=1, game.area.data.width do
        for y=1, game.area.data.height do
            local index = game.area:getTileIndex(x, y)

            -- Process tiles
            love.graphics.setColor(255, 255, 255)
            if DBGX == x and DBGY == y then
                love.graphics.setColor(0, 255, 255)
            end
            for i, layer in ipairs(game.area.data.layers) do
                -- Dont draw special tiles or floor
                if layer.name ~= 'sp' and layer.name ~= 'floor' and layer.type == 'tilelayer' then
                    local tile_id = layer.data[index]
                    if tile_id and tile_id > 0 then
                        -- Add tile's quad to spritebatch, transformed to ortho projection
                        -- spritebatch:addq(quads[tile_id], iso.toOrtho(Area.tileToWorld(x - 1.5, y - 0.5)))
                        love.graphics.drawq(tileset_image, quads[tile_id], iso.toOrtho(Area.tileToWorld(x - 1.5, y - 0.5)))
                    end
                end
            end

            -- Draw any entities in this index
            for ei, entity in ipairs(game._render_index[index] or {}) do
                entity:draw()
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
            if config.blind and not game.area.flags.lights then love.graphics.setStencil(game.blindnessStencil) end

            -- Draw area and entities
            game.drawScene()

            -- Draw blindness
            if config.blind then game:drawBlindness() end
        love.graphics.pop()
    love.graphics.pop()

    -- Clear stencil
    love.graphics.setStencil()

    -- Draw UI
    ui.draw()

    -- Draw overlay
    if game.overlay then
        love.graphics.setColor(unpack(game.overlay))
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    -- Draw debug stuff
    if config.debug and config.show_console then
        console:drawLog()
        love.graphics.print(love.timer.getFPS(), love.graphics.getWidth() - 50, 0)
    end
end

-- Draw blindness circles around a point
function game:drawBlindness()
    if not game.area.flags.lights then
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
end

function game.flushEntityQueue()
    for i, entity in ipairs(game._entity_queue) do
        table.insert(game.entities, entity)
        game._entity_queue[i] = nil
    end
end

function game:update(dt)
    -- Check major state
    game:checkMajorState()

    -- Update global time manager
    time:update(dt)

    -- Update extra timers
    for i, timer in pairs(game.timers) do
        game.timers[i] = timer - dt
    end
    game.handleTimers()

    -- Update player
    game.player:update(dt)

    -- Add pending entities
    game.flushEntityQueue()

    -- Update entities
    remove_if(game.entities, function(entity)
        if entity ~= nil then 
            entity:update(dt)

            if not entity.dead then 
                -- Check for collisions
                if entity.hit == "p_attack" then
                    for i, entity2 in ipairs(game.entities) do
                        if entity2.hit == "enemy" then
                            local a, b, c, d = entity:getCollisionRect()
                            local e, f, g, h = entity2:getCollisionRect()
                            if rect_intersects(a,b,c,d,e,f,g,h) then
                                entity2:getHit(entity)
                                entity:die()
                            end
                        end
                    end
                end

                -- Check player collisions

                -- Module pickup
                if entity.hit == "module" then
                    local a,b,c,d = entity:getCollisionRect()
                    local e,f,g,h = game.player:getCollisionRect()
                    if rect_intersects(a,b,c,d,e,f,g,h) then
                        audio.play('pickup')
                        entity:die()
                        game.state.modules = game.state.modules + 1
                    end
                end

                if entity.hit == "e_attack" then
                    local a,b,c,d = entity:getCollisionRect()
                    local e,f,g,h = game.player:getCollisionRect()
                    if rect_intersects(a,b,c,d,e,f,g,h) then
                        entity:die()
                        game.player:getHit(entity)
                    end
                end

                if entity.hit == "enemy" and entity.damage > 0 and game.timers.enemy_collide < 0 then
                    local a,b,c,d = entity:getCollisionRect()
                    local e,f,g,h = game.player:getCollisionRect()
                    if rect_intersects(a,b,c,d,e,f,g,h) then
                        game.timers.enemy_collide = 1
                        game.player:getHit(entity)
                    end
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
            game.loadArea(game.area.name)
        end
    end


    -- Game keys
    if key == keys.weapon then
        game.player:cycleWeapon()
    end
end

return game
