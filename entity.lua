Entity = leaf.Object:extend()

function Entity:init(conf)
    self.conf = extend({
        x = 0,
        y = 0,
        w = 32,
        h = 32,
        speed = 1,
        bound = 12,
        hit = "none",
        damage = 0,
    }, conf or {})

    -- Cleanup state
    self.dead = false

    -- Collision data
    self.hit = self.conf.hit
    self.damage = self.conf.damage
    self.bound = self.conf.bound

    -- Physics
    self.x = self.conf.x
    self.y = self.conf.y
    self.w = self.conf.w
    self.h = self.conf.h
    self.speed = self.conf.speed 
end

function Entity:update(dt) end
function Entity:updateSpriteMode(velx, vely) end
function Entity:getHit(e) end

function Entity:getCenter()
    return self.x - self.w / 2, self.y - self.h /2 + 2
end


function Entity:getCollisionRect()
    local x, y = self:getCenter()
    local w, h = self.bound, self.bound
    return x - w * 3 / 4, y - h * 3 / 4, x + w * 1 / 4, y + h * 1 / 4
end


function Entity:applyTransform()
    local x, y, rot, sx, sy = iso.toOrtho(self.x, self.y)
    -- love.graphics.translate(self.x + self.h / 2, self.y + self.h / 2)
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(rot)
    love.graphics.translate(-self.w / 2 - 3, -self.h * 2 - 1)
    love.graphics.scale(sx, sy)
end


function Entity:draw()
    if self.overlay then
        love.graphics.setColor(self.overlay)
    else
        color.white()
    end
    love.graphics.push()
        self:applyTransform()
        self:drawLocal()
    love.graphics.pop()
    if config.collision then
        color.debug()
        local x, y, x2, y2 = self:getCollisionRect()
        love.graphics.rectangle('line', x, y, x2 - x, y2 - y)
    end
end

function Entity:drawLocal()
end

-- Movement functions

function Entity:move(velx, vely, dt, stopOnWalls)
    velx, vely = vector.normalize(velx, vely)
    self:updateSpriteMode(velx, vely)
    velx, vely = vector.scale(velx, vely, self.speed)

    -- Project
    local next_x, next_y = self.x + velx * dt, self.y + vely * dt
    if not stopOnWalls or game.area:floorAtWorld(next_x, next_y) then
        self.x = next_x
        self.y = next_y
    end
end

function Entity:tryMove(velx, vely, dt)
    return self:move(velx, vely, dt, true)
end
