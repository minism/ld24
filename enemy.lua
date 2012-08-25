Humanoid = Entity:extend()

function Humanoid:init(conf)
    local conf = extend({
        w = 9,
        h = 16,
        health = 10,
    }, conf or {})
    Entity.init(self, conf)

    self.state = {
        health = self.conf.health
    }
end

function Humanoid:drawLocal()
    self.sprite:draw()
    Entity.drawLocal(self)
end

function Humanoid:updateSpriteMode(velx, vely)
    local absx = math.abs(velx)
    local absy = math.abs(vely)
    local thresh = 0.2
    if velx > thresh then
        if vely > thresh then
            self.sprite:setMode(1)
        elseif vely < -thresh then
            self.sprite:setMode(3)
        else
            self.sprite:setMode(2)
        end
    elseif velx < -thresh then
        if vely < -thresh then
            self.sprite:setMode(5)
        elseif vely > thresh then
            self.sprite:setMode(7)
        else
            self.sprite:setMode(6)
        end
    else
        if vely < -thresh then
            self.sprite:setMode(4)
        elseif vely > thresh then
            self.sprite:setMode(8)
        end
    end
end



Enemy = Humanoid:extend()

function Enemy:init(conf)
    local conf = extend({
        hit = "enemy",
    }, conf or {})
    Humanoid.init(self, conf)
    self.speed = 10
end


function Enemy:getHit(attack_entity)
    self.state.health = self.state.health - attack_entity.damage
    if self.state.health <= 0 then
        self:die()
    else
        self.overlay = {196, 128, 128}
        time:after(0.1, function() self.overlay = nil end)
    end
end

function Enemy:die()
    self.dead = true
end

function Enemy:update(dt)
    -- Calculate node list to player using astar
    local velx, vely = game.area:findPathVector(self.x, self.y)
    if velx and vely then
        self:move(velx, vely, dt)
    end
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

