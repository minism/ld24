require 'entity'
require 'sprite'

TileEntity = Entity:extend()

function TileEntity:init(conf)
    local conf = extend({
        w = 32,
        h = 32,
    }, conf or {})
    Entity.init(self, conf)
    self.x = self.x + 14
    self.y = self.y + 10
end

function TileEntity:drawLocal()
    self.sprite:draw()
end


Door = TileEntity:extend()

function Door:init(conf)
    local conf = extend({
        left = true,
    }, conf or {})
    TileEntity.init(self, conf)

    local image = self.left and assets.gfx.door_left or assets.gfx.door_right
    self.sprite = PongSprite {
        image = image,
        frame_h = 32,
        frame_w = 32,
        speed = 0.04,
    }
end

