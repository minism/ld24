Attack = Entity:extend {}

function Attack:init(conf)
    local conf = extend({
        hit = "p_attack",
    }, conf or {})
    Entity.init(self, conf)
    self.sprite = self.conf.sprite
    self.origin_x = self.x
    self.origin_y = self.y
    self.velx = self.conf.velx
    self.vely = self.conf.vely
end

function Attack:drawLocal()
    if self.hit == "e_attack" then
        color.enemy_attack()
    end
    self.sprite:draw(2, 2)
end


Bullet = Attack:extend {
    name = "Blaster"
}

function Bullet:init(conf)
    local conf = extend({
        sprite = Sprite {
            image = assets.gfx.bullet,
            frame_w = 2,
            frame_h = 2,
            speed = 0.01
        },
        w = 4,
        h = 4,
        bound = 6,
        speed = 120,
        damage = 5,
    }, conf or {})
    Attack.init(self, conf)


    if self.hit == 'p_attack' then self.speed = 150 end
    -- Play my sound
    audio.play 'gun'
end

function Bullet:update(dt)
    Attack.update(self, dt)
    if vector.length(self.x - self.origin_x, self.y - self.origin_y) > 300 then
        self.dead = true
    end
    self:move(self.velx, self.vely, dt)

    -- Die on walls
    if not game.area:bulletAtWorld(self.x - self.velx * dt, self.y - self.vely * dt) then
        self.dead = true
    end
end


Punch = Attack:extend { 
    name = "Fist"
}

function Punch:init(conf)
    local conf = extend({
        sprite = Sprite { 
            image = assets.gfx.punch,
            frame_w = 8,
            frame_h = 8,
            speed = 0.015
        },
        w = 8,
        h = 8,
        bound = 12,
        damage = 10,
    }, conf or {})
    Attack.init(self, conf)

    self.x = self.x + self.velx * 2 + 4
    self.y = self.y + self.vely * 2 + 3

    -- Play my sound
    audio.play 'punch'
end

function Punch:update(dt)
    Attack.update(self, dt)
    if self.sprite.loops > 0 then
        self.dead = true
    end
end

function Punch:draw()
    local x, y, rot, sx, sy = iso.toOrtho(self.x, self.y)
    love.graphics.push()
        love.graphics.translate(x - 16, y - 16)
        love.graphics.rotate(rot)
        love.graphics.scale(sx, sy)
        love.graphics.rotate(vector.angle(self.velx, self.vely) + math.pi * 3 / 4)
        love.graphics.translate(-self.w/2, -self.h/2)
        self.conf.sprite:draw(0, 0)
    love.graphics.pop()

    if config.collision then
        color.debug()
        local x, y, x2, y2 = self:getCollisionRect()
        love.graphics.rectangle('line', x, y, x2 - x, y2 - y)
    end
end