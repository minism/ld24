Entity = Object:extend {
    default = {
        x = 0,
        y = 0,
        w = 32,
        h = 32,
    },
}

function Entity:init(conf)
    self.conf = {}
    _.extend(self.conf, self.default)
    _.extend(self.conf, conf or {})

    -- Physics
    self.x = self.conf.x
    self.y = self.conf.y
    self.w = self.conf.w
    self.h = self.conf.h
    self.vel = vector.new()
end

function Entity:update(dt)
    self:step(dt)
end

-- Step physics
function Entity:step(dt)
    self.x = self.x + self.vel.x * dt
    self.y = self.y + self.vel.y * dt
end


function Entity:applyTransform()
    local x, y, rot, sx, sy = iso.toOrtho(self.x, self.y)
    -- love.graphics.translate(self.x + self.h / 2, self.y + self.h / 2)
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(rot)
    love.graphics.translate(-self.w / 2, -self.h * 2)
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
