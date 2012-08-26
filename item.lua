Item = Entity:extend()

function Item:init(conf)
    local conf = extend({
        w = 8,
        h = 8,
        velx = 0,
        vely = 0,
        speed = 30,
    }, conf or {})
    Entity.init(self, conf)
    self.velx = self.conf.velx
    self.vely = self.conf.vely
end

function Item:update(dt)
    -- Apply friction
    self.velx = self.velx * 0.9
    self.vely = self.vely * 0.9
    if math.abs(self.velx) < 0.01 then self.velx = 0 end
    if math.abs(self.vely) < 0.01 then self.vely = 0 end
    self:tryMove(self.velx, self.vely, dt)
end


Module = Item:extend()

function Module:init(conf)
    local conf = extend({
        hit = "module"
    }, conf or {})
    Item.init(self, conf)
    self.sprite = Sprite {
        image = assets.gfx.module,
        frame_w = 8,
        frame_h = 8,
        speed = 0.5,
    }
end

