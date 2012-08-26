require 'entity'
require 'item'


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
    if absx < thresh and absy < thresh then
        self.sprite:pause()
    else
        self.sprite:resume()
    end
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
        speed = 20,
        hit = "enemy",
    }, conf or {})
    Humanoid.init(self, conf)

    -- Setup AI 
    self.ai_state = 'idle'
    self.ai_timer = 0
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
    -- Update ai timer
    self.ai_timer = self.ai_timer - dt
    if self.ai_timer < 0 then
        self.ai_timer = self.speed / 20
        self:decide()
    end

    -- Calculate node list to player using astar
    local vec_px, vec_py, cost = game.area:findPathVector(self.x, self.y)
    if self.ai_state == 'move_random' then
        self:move(0, 0, dt)
    elseif vec_px and vec_py then
        if self.ai_state == 'move_player' then
            -- Move towards player
            self:move(vec_px, vec_py, dt)
        elseif self.ai_state == 'move_away' then
            -- Move away from player
            self:tryMove(-vec_px, -vec_py, dt)
        end
    else
        self:move(0, 0, dt)
    end
end

Guard = Enemy:extend()

function Guard:init(conf)
    Enemy.init(self, conf)
    self.sprite = MultiSprite {
        image = assets.gfx.guard,
        frame_w = 16,
        frame_h = 16,
        modes = 8,
    }
end

function Guard:decide()
    local vec_px, vec_py, cost = game.area:findPathVector(self.x, self.y)
    if cost < 10 then
        self.ai_state = 'move_player'
    end

    local fire_range = math.random(4, 7)
    if cost <= fire_range then
        self.ai_state = 'fire'
        self:updateSpriteMode(vec_px, vec_py)
        -- Calculate vector to player, offset  by random amount
        local miss_amount = 0.5
        local offset = math.random() * miss_amount - miss_amount / 2 - 0.1
        local fire_x, fire_y = vector.rotate(game.player.x - self.x, game.player.y - self.y, offset)
        game.addEntity(Bullet {
            x = self.x,
            y = self.y,
            velx = fire_x,
            vely = fire_y,
            hit = "e_attack",
        })
    end
end

Scientist = Enemy:extend()

function Scientist:init(conf)
    local conf = extend({
        speed = 30,
    }, conf or {})
    Enemy.init(self, conf)
    self.sprite = MultiSprite {
        image = assets.gfx.scientist,
        frame_w = 16,
        frame_h = 16,
        modes = 8,
    }
end

function Scientist:decide()
    local vec_px, vec_py, cost = game.area:findPathVector(self.x, self.y)
    if cost and cost < 5 then
        self.ai_state = 'move_away'
    else
        self.ai_state = 'move_random'
    end
end

function Scientist:die()
    Enemy.die(self)
    
    -- Drop modules
    -- local nmodules = math.random(1, 3)
    -- for i=1, nmodules do
    --     local theta = math.random() * math.pi * 2
    --     local drop_velx, drop_vely = vector.rotate(1, 0, theta)
    --     local mod = DNAModule {
    --         x = self.x,
    --         y = self.y,
    --         velx = drop_velx,
    --         vely = drop_vely,
    --     }
    --     game.addEntity(mod)
    -- end
end


