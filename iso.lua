-- Isometric helper functions
local iso = {
    angle = math.atan2(1, 1),
    scale = {
        x = 1,
        y = 0.5,
    },
}


-- Return the orthographic projection of world coordinates
-- Returns x, y, rot, sx, sy
function iso.toOrtho(x, y)
    return x, y, -iso.angle, 1 / iso.scale.x, 1 / iso.scale.y
end


-- Apply isometric projection matrix to stack
function iso.applyMatrix()
    love.graphics.scale(iso.scale.x, iso.scale.y)
    love.graphics.rotate(iso.angle)
end

return iso
