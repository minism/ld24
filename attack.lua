Attack = Entity:extend()

function Attack:init(conf)
    Entity.init(self, conf)
    self.sprite = self.conf.sprite
    self.origin_x = self.x
    self.origin_y = self.y
    self.velx = self.conf.velx
    self.vely = self.conf.vely
end

function Attack:drawLocal()
    self.sprite:draw(0, 0)
end


Bullet = Attack:extend()

function Bullet:init(conf)
    local conf = extend({
        sprite = Sprite {
            image = assets.gfx.bullet,
            frame_w = 1,
            frame_h = 1,
            speed = 0.01
        },
        w = 4,
        h = 4,
        speed = 150,
    }, conf or {})
    Attack.init(self, conf)
end

function Bullet:update(dt)
    if vector.length(self.x - self.origin_x, self.y - self.origin_y) > 300 then
        self.dead = true
    end
    self:move(self.velx, self.vely, dt)
end


Punch = Attack:extend()

function Punch:init(conf)
    local conf = extend({
        sprite = Sprite { 
            image = assets.gfx.punch,
            frame_w = 8,
            frame_h = 8,
            speed = 0.015
        },
        w = 16,
        h = 16,
    }, conf or {})
    Attack.init(self, conf)
end

function Punch:update(dt)
    Attack.update(self, dt)
    if self.sprite.loops > 0 then
        self.dead = true
    end
end

function Punch:draw()
    local x, y, rot, sx, sy = iso.toOrtho(px + self.x, py + self.y)
    love.graphics.push()
        love.graphics.translate(x, y)
        love.graphics.rotate(rot)
        love.graphics.translate(-2, 0)
        love.graphics.scale(sx, sy)
        love.graphics.rotate(vector.angle(self.x, self.y) - math.pi / 4)
        self.conf.sprite:draw(0, 0)
    love.graphics.pop()
end