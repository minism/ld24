Attack = Entity:extend()

-- function Attack:init(conf)
--     Entity.init(self, conf)
--     self.sprite = Sprite { 
--         image = self.conf.sprite,
--     }
-- end

function Attack:drawLocal()
    self.conf.sprite:draw(self.x, self.y)
end

Punch = Attack:extend()

function Punch:init(conf)
    local conf = extend({
        sprite = Sprite { 
            image = assets.gfx.punch,
            frame_w = 8,
            frame_h = 8,
            speed = 0.05
        }
    }, conf or {})
    Attack.init(self, conf)
end

