-- Animated sprite class
Sprite = leaf.Object:extend()

DEFAULT_SPEED = 0.1

function Sprite:init(prop)
    self.speed = prop.speed or DEFAULT_SPEED
    self.image = prop.image
    self.quads = build_quads(self.image, prop.frame_w, prop.frame_h)
    self.frame = 1
    self.timer = time:every(self.speed, function() self:advanceFrame() end)
end

function Sprite:draw(x, y)
    local quad = self.quads[self.frame]
    local x = x or 0
    local y = y or 0
    if quad then
        love.graphics.drawq(self.image, self.quads[self.frame], x, y)
    end
end

function Sprite:advanceFrame()
    self.frame = self.frame % #self.quads + 1
end


MultiSprite = Sprite:extend()

-- Sprite with modes that animate on columns
function MultiSprite:init(prop)
    Sprite.init(self, prop)
    self.modes = prop.modes
    self.mode = 1
    self.mframe = 1
end

function MultiSprite:setMode(mode)
    self.mode = mode
end

function MultiSprite:advanceFrame()
    self.mframe = self.mframe % (#self.quads / self.modes) + 1
    self.frame = (self.mframe - 1) * self.modes + self.mode
end
