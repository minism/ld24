Item = Entity:extend()

function Item:init(conf)
    local conf = extend({
        velx = 0,
        vely = 0,
    }, conf or {})
    Entity.init(self, conf)
    self.velx = self.conf.velx
    self.vely = self.conf.vely
end


DNAModule = Item:extend()

function DNAModule:init(conf)
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