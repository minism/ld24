require 'entity'

Player = Entity:extend()

function Player:init(...)
    Entity.init(self, {
        w = 8,
        h = 16,
    })

    self.stats = {
        speed = 70,
    }
end

function Player:drawLocal()
    color.white()
    love.graphics.rectangle('fill', 0, 0, self.w, self.h)

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

    velx, vely = vector.normalize(velx, vely)

    -- Convert to world
    velx, vely = vector.scale(velx, vely, self.stats.speed)
    velx, vely = vector.rotate(velx, vely, -iso.angle)

    -- Project
    local next_x, next_y = self.x + velx * dt, self.y + vely * dt

    -- Successful move if floor exists
    if game.area:floorAt(next_x, self.y) then
        self.x = next_x
    end
    if game.area:floorAt(self.x, next_y) then
        self.y = next_y
    end
end
