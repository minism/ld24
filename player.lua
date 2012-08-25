require 'entity'

Player = Entity:extend()


function Player:drawLocal()
    color.debug()
    love.graphics.rectangle('fill', 0, 0, 2, 2)
end

