-- Animated sprite class
Sprite = Object:extend()

DEFAULT_SPEED = 0.1

function Sprite:init(prop)
    self.speed = prop.speed or DEFAULT_SPEED
    self.image = prop.image
    self.quads = build_quads(self.image, prop.frame_w, prop.frame_h)
    self.frame = 1
    self.timer = time:every(self.speed, function() self:advanceFrame() end)
end

function Sprite:draw()
    love.graphics.drawq(self.image, self.quads[self.frame], 0, 0)
end


MultiSprite = Sprite:extend()

-- Sprite with modes that animate on columns
function MultiSprite:init(prop)
    Sprite.init(self, prop)
    self.modes = prop.modes
end

function MultiSprite:setMode(mode)
    self.frame = mode
end

function MultiSprite:advanceFrame()
    self.frame = (self.frame + self.modes) % #self.quads
end
