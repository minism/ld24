require 'entity'
require 'sprite'
require 'enemy'
require 'attack'

Player = Humanoid:extend()

function Player:init(conf)
    Humanoid.init(self, conf)

    self.stats = {
        speed = 10,
        vision = 10,
        vitality = 10,
        spatial = 10,
    }

    self.sprite = MultiSprite {
        image = assets.gfx.guy,
        frame_w = 16,
        frame_h = 16,
        modes = 8,
    }

    -- Player time instance
    self.time = Time()

    self.attack_ready = true
    self.attack_sprite = nil
end

-- Get a scaled stat
local stat_scales = {
    speed = 7,
    vision = 15,
}
function Player:stat(stat)
    local scale = stat_scales[stat] or 1
    return self.stats[stat] * scale
end

function Player:processInput()
    -- Calculate normalized attack vector in iso space
    local velx, vely = 0, 0
    if keys.isDown('a_left') then
        velx = -1
    elseif keys.isDown('a_right') then
        velx = 1
    end
    if keys.isDown('a_up') then 
        vely = -1
    elseif keys.isDown('a_down') then 
        vely = 1
    end
    velx, vely = vector.normalize(velx, vely)
    if vector.length(velx, vely) > 0 then
        self:attack(velx, vely)
    end
end

function Player:getAttackTime()
    return self:stat('spatial') * 0.1
end

-- Attack on a vector with current weapon
function Player:attack(x, y)
    if self.attack_ready then
        self.attack_ready = false

        -- Insert attack entity
        game.addEntity(Punch {
            x = self.x,
            y = self.y,
        })

        self.time:after(self:getAttackTime(), function()
            self.attack_ready = true
        end)
    end
end

function Player:update(dt)
    -- Update internal time handler
    self.time:update(dt)

    -- Process commands
    self:processInput()

    -- Calculate normalized velocity in iso space
    local velx, vely = 0, 0
    if keys.isDown('left') then
        velx = -1
    elseif keys.isDown('right') then
        velx = 1
    end
    if keys.isDown('up') then 
        vely = -1
    elseif keys.isDown('down') then 
        vely = 1
    end

    -- Calculate screen velocity vector and update sprite
    velx, vely = iso.makeVector(velx, vely, self:stat('speed'))
    self:updateSpriteMode(velx, vely)

    -- Project
    local next_x, next_y = self.x + velx * dt, self.y + vely * dt

    -- Successful move if floor exists
    if game.area:floorAtWorld(next_x, self.y) then
        self.x = next_x
    end
    if game.area:floorAtWorld(self.x, next_y) then
        self.y = next_y
    end
end

