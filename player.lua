require 'entity'
require 'sprite'

Player = Entity:extend()

function Player:init(...)
    Entity.init(self, {
        w = 9,
        h = 16,
    })

    self.stats = {
        speed = 70,
        vision = 120,
    }

    self.sprite = assets.sprites.guy
end

function Player:drawLocal()
    self.sprite:draw()
    Entity.drawLocal(self)
end

function Player:updateSpriteMode(velx, vely)
    if velx > 0 then
        if vely > 0 then
            self.sprite:setMode(1)
        elseif vely < 0 then
            self.sprite:setMode(3)
        else
            self.sprite:setMode(2)
        end
    elseif velx < 0 then
        if vely < 0 then
            self.sprite:setMode(5)
        elseif vely > 0 then
            self.sprite:setMode(7)
        else
            self.sprite:setMode(6)
        end
    else
        if vely < 0 then
            self.sprite:setMode(4)
        elseif vely > 0 then
            self.sprite:setMode(8)
        end
    end
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
    if math.abs(velx) < 0.001 then velx = 0 end
    if math.abs(vely) < 0.001 then vely = 0 end

    -- Update sprite based on velocity vector
    self:updateSpriteMode(velx, vely)

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
