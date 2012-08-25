Entity = Object:extend {
    conf = {
        x = 0,
        y = 0,
    },
}

function Entity:init(conf)
    _.extend(self.conf, conf or {})

    self.x = self.conf.x
    self.y = self.conf.y
end

function Entity:applyTransform()
    local x, y, rot, sx, sy = iso.toOrtho(self.x, self.y)
    love.graphics.translate(x, y)
    love.graphics.rotate(rot)
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
