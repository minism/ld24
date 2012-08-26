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
    if self.sprite then self.sprite:draw(x, 0, 0, sx, 1) end
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


Chamber = TileEntity:extend {
    
}

function Chamber:init(conf)
    local conf = extend({

    }, conf or {})
    TileEntity.init(self, conf)

    self.sprite = Sprite {
        speed = 0,
        image = assets.gfx.chamber,
        frame_h = 32,
        frame_w = 32,
    }

    self.used = self.conf.used
end

function Chamber:update(dt)
    if self.used then
        self.sprite.frame = 2
    else
        self.sprite.frame = 1
    end
end



Subject = TileEntity:extend {
    
}

function Subject:init(conf)
    local conf = extend({
        xofs = -1,
        yofs = 0,
    }, conf or {})
    TileEntity.init(self, conf)

    self.sprite = Sprite {
        speed = 0,
        image = assets.gfx.subject,
        frame_h = 32,
        frame_w = 32,
    }

    self.state = true
end


function Subject:update(dt)
    TileEntity.update(dt)
    if self.state then
        self.sprite.frame = 1
    else
        self.sprite.frame = 2
    end
end



Light = TileEntity:extend()

function Light:init(conf)
    local conf = extend({
        xofs = -1,
        yofs = 0,
    }, conf or {})
    TileEntity.init(self, conf)
end
