Humanoid = Entity:extend()

function Humanoid:updateSpriteMode(velx, vely)
    if velx > 0 then
        if vely > 0 then
            self.sprite:setMode(1)
        elseif vely < 0 then
            self.sprite:setMode(3)
        else
            self.sprite:setMode(2)
        end
    elseif velx < 0 then
        if vely < 0 then
            self.sprite:setMode(5)
        elseif vely > 0 then
            self.sprite:setMode(7)
        else
            self.sprite:setMode(6)
        end
    else
        if vely < 0 then
            self.sprite:setMode(4)
        elseif vely > 0 then
            self.sprite:setMode(8)
        end
    end
end

Enemy = Entity:extend()


Guard = Enemy:extend()

function Guard:init(conf)
    Enemy.init(self, conf)
    self.sprite = assets.sprites.guy
end

