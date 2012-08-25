Entity = Object:extend {
    default = {
        x = 0,
        y = 0,
    },
}

function Entity:init(conf)
    self.conf = {}
    _.extend(self.conf, self.default)
    _.extend(self.conf, conf or {})

    -- Physics
    self.x = self.conf.x
    self.y = self.conf.y
    self.velx = 0
    self.vely = 0
end

function Entity:update(dt)
    self:step(dt)
end

-- Step physics
function Entity:step(dt)
    self.x = self.x + self.velx * dt
    self.y = self.y + self.vely * dt
end


function Entity:applyTransform()
    local x, y, rot, sx, sy = iso.toOrtho(self.x, self.y)
    love.graphics.translate(self.x, self.y)
    -- love.graphics.rotate(rot)
    -- love.graphics.scale(sx, sy)
end


function Entity:draw()
    love.graphics.push()
        self:applyTransform()
        self:drawLocal()
    love.graphics.pop()
end

function Entity:drawLocal() end
