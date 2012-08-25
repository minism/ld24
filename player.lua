require 'entity'

Player = Entity:extend()

function Player:init(...)
    Entity.init(self, {
        w = 8,
        h = 16,
    })

    self.stats = {
        speed = 40,
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

    -- Copy to physics vector
    self.vel.x, self.vel.y = velx, vely


    Entity.update(self, dt)
end
