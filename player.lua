require 'entity'
require 'sprite'
require 'enemy'

Player = Humanoid:extend()

function Player:init(...)
    Entity.init(self, {
        w = 9,
        h = 16,
    })

    self.stats = {
        speed = 70,
        vision = 150,
    }

    self.sprite = assets.sprites.guy
end

function Player:drawLocal()
    self.sprite:draw()
    Entity.drawLocal(self)
end

function Player:update(dt)
    -- Calculate normalized velocity in iso space
    local velx, vely = 0, 0
    if love.keyboard.isDown('a') then
        velx = -1
    elseif love.keyboard.isDown('d') then 
        velx = 1
    end

    if love.keyboard.isDown('w') then 
        vely = -1
    elseif love.keyboard.isDown('s') then 
        vely = 1
    end

    -- Calculate screen velocity vector and update sprite
    velx, vely = iso.makeVector(velx, vely, self.stats.speed)
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
