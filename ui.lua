local ui = {
    height = 70
}

function ui.drawBox(left, top, width, height)
    color.ui_bg()
    love.graphics.rectangle("fill", left, top, width, height)
    color.ui_border()
    local border = 3
    for i=1,1 do
        local frame = border * i
        love.graphics.setLineWidth(frame)
        love.graphics.rectangle("line", left, top, width, height)
    end
end


function ui.draw()
    local left, top = 0, love.graphics.getHeight() - ui.height
    local right, bottom = love.graphics.getWidth(), love.graphics.getHeight()
    local center_x = (right - left) / 2
    local box_width, box_height = 300, bottom - top

    local box1 = {left, top, box_width, box_height}
    local box2 = {center_x - box_width /2, top, box_width, box_height}
    local box3 = {right - box_width, top, box_width, box_height}

    -- Draw player state
    ui.drawBox(unpack(box1))

    -- Draw game state
    ui.drawBox(unpack(box2))

    -- Draw player stats
    ui.drawBox(unpack(box3))

end


return ui
