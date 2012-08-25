Humanoid = Entity:extend()

function Humanoid:init(conf)
    local conf = conf or {}
    _.extend(conf, {
        w = 9,
        h = 16,
    })
    Entity.init(self, conf)
end

function Humanoid:drawLocal()
    self.sprite:draw()
    Entity.drawLocal(self)
end

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



Enemy = Humanoid:extend()

function Enemy:init(conf)
    Humanoid.init(self, conf)
    self.speed = 10
end

function Enemy:update(dt)
    -- Calculate node list to player using astar
    local velx, vely = game.area:findPathVector(self.x, self.y)
    if velx and vely then
        self:tryMove(velx, vely, dt)
    end
end

function Enemy:tryMove(velx, vely, dt)
    velx, vely = vector.normalize(velx, vely)
    velx, vely = vector.scale(velx, vely, self.speed)
    self:updateSpriteMode(velx, vely)

    -- Project
    local next_x, next_y = self.x + velx * dt, self.y + vely * dt
    self.x = next_x
    self.y = next_y
end


Guard = Enemy:extend()

function Guard:init(conf)
    Enemy.init(self, conf)
    self.sprite = MultiSprite {
        image = assets.gfx.guy,
        frame_w = 16,
        frame_h = 16,
        modes = 8,
    }
end

