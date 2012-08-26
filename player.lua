require 'entity'
require 'sprite'
require 'enemy'
require 'attack'

Player = Humanoid:extend()

local ATTACK_LENGTH = 4

function Player:init(conf)
    Humanoid.init(self, conf)

    self.stats = {
        speed = config.starting_stat,
        focus = config.starting_stat,
        vision = config.starting_stat,
        vitality = config.starting_stat,
    }

    self.sprite = MultiSprite {
        image = assets.gfx.guy,
        frame_w = 16,
        frame_h = 16,
        modes = 8,
    }

    self.state.weapons = {
        Punch
    }
    self.state.weapon = self.state.weapons[1]

    -- Player time instance
    self.time = Time()
    self.attack_ready = true
end

function Player:cycleWeapon()
    local index = 1
    for i, weapon in ipairs(self.state.weapons) do
        if weapon == self.state.weapon then
            index = i
        end
    end
    self.state.weapon = self.state.weapons[(index % #self.state.weapons) + 1]
end

-- Get a scaled stat
local stat_scales = {
    speed = 4,
    vision = 12,
    vitality = 4,
    focus = 1 / 6,
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
    velx, vely = iso.makeVector(velx, vely, ATTACK_LENGTH)
    if vector.length(velx, vely) > 0 then
        self:attack(velx, vely)
    end
end

function Player:getAttackTime()
    return 1 / self:stat('focus')
end

-- Attack on a vector with current weapon
function Player:attack(x, y)
    if self.attack_ready then
        self.attack_ready = false

        -- Insert attack entity
        local px, py = self:getCenter()
        game.addEntity(self.state.weapon {
            x = px,
            y = py,
            velx = x,
            vely = y,
            speed = 200,
        })

        self.time:after(self:getAttackTime(), function()
            self.attack_ready = true
        end)
    end
end

function Player:update(dt)
    -- Store last tile position
    local last_x, last_y = self.x, self.y
    local last_tx, last_ty = Area.worldToTile(self.x, self.y)

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
    else
        game.checkPlayerWallEvent(next_x, self.y)
    end

    if game.area:floorAtWorld(self.x, next_y) then
        self.y = next_y
    else
        game.checkPlayerWallEvent(self.x, next_y)
    end


    -- If we moved tiles, alert game
    local tx, ty = Area.worldToTile(self.x, self.y)
    if last_tx ~= tx or last_ty ~= ty then
        game.checkPlayerTileEvent(self.x, self.y)
    end

    -- If we moved position, alert game
    if last_x ~= self.x or last_y ~= self.y then
        game.checkPlayerPositionEvent(self.x, self.y)
    end
end

