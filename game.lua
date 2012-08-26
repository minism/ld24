require 'area'
require 'player'
require 'enemy'
require 'item'

local game = {}
game.entities = {}
game._entity_queue = {}


function game.setup()
    -- Load everything
    assets.load()
    tilehelper.load()

    -- Setup player
    game.player = Player()

    -- Setup active area
    game.area = nil

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

    }

    -- Game state
    game.state = {
        subjects = 100,
        modules = 0,
    }

    -- Test
    game.loadArea('test')
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
    }
    if handlers[id] then handlers[id]() end
end


function game.loadArea(areaname)
    -- Dump previous data
    game.entities = {}

    -- Load area data
    game.area = Area(areaname)
    game.area:load()

    -- React to any sp tile init data
    for i, spdata in ipairs(game.area.sp_init) do game.processSpecialTile(spdata) end
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


function game:draw()
    -- Draw in camera projection
    love.graphics.push()
    game.camera:applyMatrix()

        -- Draw in isometric projection
        love.graphics.push()
        if config.iso == true then iso.applyMatrix() end

            -- Draw blindness
            if config.blind then love.graphics.setStencil(game.blindnessStencil) end

            -- Draw area
            game.area:draw()

            -- Draw entities
            for i, entity in ipairs(game.entities) do
                entity:draw()
            end

            -- Draw player
            game.player:draw()

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
            if entity.hit == "module" and not entity.dead then
                local a,b,c,d = entity:getCollisionRect()
                local e,f,g,h = game.player:getCollisionRect()
                if rect_intersects(a,b,c,d,e,f,g,h) then
                    entity:die()
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
    end
end

return game
