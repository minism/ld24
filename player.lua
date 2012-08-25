require 'entity'

Player = Entity:extend()

function Player:init(...)
    Entity.init(self, ...)

    self.stats = {
        speed = 20,
    }
end

function Player:drawLocal()
    color.debug()
    love.graphics.rectangle('fill', 0, 0, 2, 2)
end

function Player:update(dt)
    if love.keyboard.isDown('a') then     
        self.velx = -self.stats.speed
    elseif love.keyboard.isDown('d') then 
        self.velx = self.stats.speed
    else
        self.velx = 0
    end

    if love.keyboard.isDown('w') then 
        self.vely = -self.stats.speed
    elseif love.keyboard.isDown('s') then 
        self.vely = self.stats.speed
    else
        self.vely = 0
    end


    Entity.update(self, dt)
end
