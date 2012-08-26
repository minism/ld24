require 'entity'
require 'sprite'

TileEntity = Entity:extend()

function TileEntity:init(conf)
    local conf = extend({
        w = 32,
        h = 32,
        left = true,
    }, conf or {})
    Entity.init(self, conf)
    self.x = self.x + 14
    self.y = self.y + 10
end

function TileEntity:drawLocal()
    sx = self.conf.left and 1 or -1
    x = self.conf.left and 0 or self.w
    self.sprite:draw(x, 0, 0, sx, 1)
end


Door = TileEntity:extend {
    range = 50,
}

function Door:init(conf)
    local conf = extend({
    }, conf or {})
    TileEntity.init(self, conf)

    local image = assets.gfx.door_left
    self.sprite = PongSprite {
        image = image,
        frame_h = 32,
        frame_w = 32,
        speed = 0.04,
    }
    self.sprite.reverse = true
end

