Entity = leaf.Object:extend()

function Entity:init(conf)
    self.conf = extend({
        x = 0,
        y = 0,
        w = 32,
        h = 32,
        speed = 1,
    }, conf or {})

    -- Cleanup state
    self.dead = false

    -- Physics
    self.x = self.conf.x
    self.y = self.conf.y
    self.w = self.conf.w
    self.h = self.conf.h
    self.speed = self.conf.speed 
end

function Entity:update(dt) end
function Entity:updateSpriteMode(velx, vely) end

function Entity:getCenter()
    return self.x - self.w / 2, self.y - self.h /2
end


function Entity:applyTransform()
    local x, y, rot, sx, sy = iso.toOrtho(self.x, self.y)
    -- love.graphics.translate(self.x + self.h / 2, self.y + self.h / 2)
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(rot)
    love.graphics.translate(-self.w / 2 - 3, -self.h * 2 - 1)
    love.graphics.scale(sx, sy)
end


function Entity:draw()
    love.graphics.push()
        self:applyTransform()
        self:drawLocal()
    love.graphics.pop()
end

function Entity:drawLocal()
end

-- Movement functions

function Entity:move(velx, vely, dt)
    velx, vely = vector.normalize(velx, vely)
    self:updateSpriteMode(velx, vely)
    velx, vely = vector.scale(velx, vely, self.speed)

    -- Project
    local next_x, next_y = self.x + velx * dt, self.y + vely * dt
    self.x = next_x
    self.y = next_y
end
