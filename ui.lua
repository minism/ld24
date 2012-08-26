local ui = {
    height = 80
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

function ui.drawBar(left, top, width, amount)
    -- Draw bar
    color.ui_bar()
    local height =  assets.font.ui:getHeight()
    love.graphics.rectangle("fill", left, top, width * amount, height)

    -- Draw frame
    color.ui_font()
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", left, top, width, height)
end


function ui.draw()
    -- Draw main UI
    love.graphics.setFont(assets.font.ui)
    local left, top = 0, love.graphics.getHeight() - ui.height
    local right, bottom = love.graphics.getWidth(), love.graphics.getHeight()
    local center_x = (right - left) / 2
    local box_width, box_height = 300, bottom - top
    local padding = 12
    local line_spacing = 30
    local col_spacing = 100
    local box1 = {left, top, box_width, box_height}
    local box2 = {center_x - box_width /2, top, box_width, box_height}
    local box3 = {right - box_width, top, box_width, box_height}

    -- Draw player state
    ui.drawBox(unpack(box1))
        color.ui_font()
        love.graphics.print("WEAPON", box1[1] + padding, box1[2] + padding)
        love.graphics.print("HEALTH", box1[1] + padding, box1[2] + padding + line_spacing)

        -- Draw health
        color.ui_font2()
        local weapon_name = game.player.state.weapon.name
        love.graphics.print(weapon_name, box1[1] + padding + col_spacing, box1[2] + padding)
        local health_percent = game.player.state.health / game.player:stat('vitality')
        ui.drawBar(box1[1] + padding + col_spacing, box1[2] + padding + line_spacing, 120, health_percent)

    -- Draw game state
    ui.drawBox(unpack(box2))

    -- Draw player stats
    ui.drawBox(unpack(box3))

end


return ui
