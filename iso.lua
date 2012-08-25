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


function iso.toIso(x, y)
    local x, y = vector.rotate(x, y, iso.angle)
    x = x * iso.scale.x
    y = y * iso.scale.y
    return x, y
end

-- Convert a world vector to iso vector with a magnitude
function iso.makeVector(x, y, mag)
    x, y = vector.normalize(x, y)
    x, y = vector.scale(x, y, mag)
    x, y = vector.rotate(x, y, -iso.angle)
    if math.abs(x) < 0.001 then x = 0 end
    if math.abs(y) < 0.001 then y = 0 end
    return x, y
end

-- Apply isometric projection matrix to stack
function iso.applyMatrix()
    love.graphics.scale(iso.scale.x, iso.scale.y)
    love.graphics.rotate(iso.angle)
end

return iso
