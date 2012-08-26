local ui = {
    height = 90
}

function ui.drawBox(left, top, width, height, bg, border)
    local color_bg = bg or color.ui_bg
    local color_border = border or color.ui_border
    color_bg()
    love.graphics.rectangle("fill", left, top, width, height)
    color_border()
    local border = 3
    for i=1,1 do
        local frame = border * i
        love.graphics.setLineWidth(frame)
        love.graphics.rectangle("line", left, top, width, height)
    end
end

function ui.drawBar(left, top, width, amount, origin)
    -- Draw bar
    color.ui_bar()
    local height =  assets.font.ui:getHeight()
    love.graphics.rectangle("fill", left, top, width * amount, height)

    -- Draw origin
    if origin then
        color.ui_font()
        love.graphics.setLineWidth(1)
        local ox = config.starting_stat / config.max_stat
        love.graphics.line(left + width * ox, top, left + width * ox, top + height)
    end

    -- Draw frame
    color.ui_font()
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", left, top, width, height)
end


local function rprint(text, x, y, w)
    love.graphics.printf(text, x, y, w, 'right')
end


function ui.draw()
    -- Draw main UI
    love.graphics.setFont(assets.font.ui)
    local left, top = 0, love.graphics.getHeight() - ui.height
    local right, bottom = love.graphics.getWidth(), love.graphics.getHeight()
    local center_x = (right - left) / 2
    local box_width, box_height = 300, bottom - top
    local padding = 8
    local line_spacing = 20
    local col_spacing = 100
    local box1 = {left, top, box_width, box_height}
    local box2 = {center_x - box_width /2, top, box_width, box_height}
    local box3 = {right - box_width, top, box_width, box_height}

    -- Draw player state
    local player = game.player
    ui.drawBox(unpack(box1))
        color.ui_font()
        rprint("WEAPON:", box1[1], box1[2] + padding, col_spacing - 5)
        rprint("HEALTH:", box1[1], box1[2] + padding + line_spacing, col_spacing - 5)

        color.ui_font2()
        local weapon_name = player.state.weapon.name
        love.graphics.print(weapon_name, box1[1] + padding + col_spacing, box1[2] + padding)
        local health_percent = player.state.health / player:stat('vitality')
        ui.drawBar(box1[1] + padding + col_spacing, box1[2] + padding + line_spacing, 120, health_percent)

    -- Draw game state
    ui.drawBox(unpack(box2))
        color.ui_font()
        local bx, by = box2[1], box2[2]
        rprint("SUBJECTS LEFT:", bx, by + padding, col_spacing + 80)
        rprint("DNA MODULES:", bx, by + padding + line_spacing, col_spacing + 80)

        color.ui_font2()
        love.graphics.print(game.state.subjects, bx + col_spacing + 90, by + padding)
        love.graphics.print(game.state.modules, bx + col_spacing + 90, by + padding + line_spacing)

    -- Draw player stats
    ui.drawBox(unpack(box3))
        color.ui_font()
        local bx, by = box3[1], box3[2]
        rprint("SPEED:", bx + padding,      by + padding + line_spacing * 0, col_spacing + 10)
        rprint("FOCUS:", bx + padding,      by + padding + line_spacing * 1, col_spacing + 10)
        rprint("VISION:", bx + padding,     by + padding + line_spacing * 2, col_spacing + 10)
        rprint("VITALITY:", bx + padding,   by + padding + line_spacing * 3, col_spacing + 10)

        ui.drawBar(bx + padding + col_spacing + 20, by + padding + line_spacing * 0, 100, player.stats.speed / config.max_stat, true)
        ui.drawBar(bx + padding + col_spacing + 20, by + padding + line_spacing * 1, 100, player.stats.focus / config.max_stat, true)
        ui.drawBar(bx + padding + col_spacing + 20, by + padding + line_spacing * 2, 100, player.stats.vision / config.max_stat, true)
        ui.drawBar(bx + padding + col_spacing + 20, by + padding + line_spacing * 3, 100, player.stats.vitality / config.max_stat, true)

end


return ui
