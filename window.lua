
-- Modal dialog
Window = Context:extend()

-- Minimum time that a window must be shown
local MIN_TIME = 1
local ANIMATE_TIME = 0.1

local padding = 25

function Window:init(message, callback)
    self.message = message or ""
    self.timer = 0
    self.closable = true
    self.callback = callback
    self.margin = 200
end

function Window:update(dt)
    self.timer = self.timer + dt

    -- Pause game
    return true
end

function Window:draw()
    love.graphics.setLineWidth(2)
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local anim_alpha = math.min(self.timer / ANIMATE_TIME, 1)
    local x = self.margin
    local y = sh / 2 * (1 - anim_alpha) + self.margin
    local w = sw - self.margin * 2
    local h = anim_alpha * (sh - self.margin * 2)
    ui.drawBox(x, y, w, h, color.win_bg, color.white)



    if self.timer > ANIMATE_TIME then
        self:drawContent()
    end

    if self.closable and self.timer > MIN_TIME and math.floor(self.timer*4) % 2 == 0 then
        -- Draw indicator that we can proceed
        love.graphics.draw(assets.gfx.indicator, sw - self.margin - padding,
                           sh - self.margin - padding, 0, 3, 3)
    end
end

function Window:drawContent()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(assets.font.window)
    color.win_font()
    love.graphics.printf(self.message, self.margin + padding, self.margin + padding, 
                         sw - self.margin * 2 - padding * 2)
end

function Window:keypressed()
    if self.timer > MIN_TIME and self.closable then
        self:close()
    end
    return true
end

Window.mousepressed = Window.keypressed

function Window:close(return_val)
    if self.callback then
        self.callback(return_val)
    end
    app:popContext()
end



local Slider = leaf.Object:extend()
local Button = leaf.Object:extend()
ChamberWindow = Window:extend()


local INCUBATE_TIME = 2

function ChamberWindow:init(callback)
    Window.init(self, "", callback)
    self.closable = false
    self.choosing = true
    self.choice = 0
    self.incubate_timer = 0
    self.max_slider = 3000
    self.slider = Slider()
    self.margin = 100

    self.btn = {
        ok = Button("Incubate"),
        cancel = Button("Cancel"),
    }

    self.mutated_stats = {}
    local nbodies = 3
    for i=1, nbodies do 
        self.mutated_stats[i] = {}
        for name, value in pairs(game.player.stats) do
            self.mutated_stats[i][name] = value
        end
    end

    self.body_box = {}
end

function ChamberWindow:mutateStats()
    local max_mutation = 8
    local min_delta = 1
    local baseline = 0.5
    local optimism = 0.3
    local alpha = baseline + (1.0 - baseline) * self.slider.value
    local delta = math.max(alpha * max_mutation, min_delta)
    for i, stats in ipairs(self.mutated_stats) do
        for name, value in pairs(stats) do
            stats[name] = math.ceil(value + delta * (math.min(math.random() * 2 - 1.0 + optimism, 1.0)))
            if stats[name] < 1 then
                stats[name] = 1
            elseif stats[name] > config.max_stat then
                stats[name] = config.max_stat
            end
        end
    end
end

local function rprint(text, x, y, w)
    love.graphics.printf(text, x, y, w, 'right')
end

function ChamberWindow:drawContent()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    -- Draw heading
    local textarea = 90
    love.graphics.setFont(assets.font.window)
    color.win_font()
    -- Draw controls
    local left, right = self.margin + padding, sw - self.margin - padding
    local top = self.margin + padding, sh - self.margin - padding

    if self.choosing then
        -- Draw selection
        love.graphics.printf("WELCOME TO HYPERINCUBATOR v1.0.  SELECT A DURATION", self.margin + padding, self.margin + padding, sw - self.margin * 2 - padding * 2)
        self.slider:draw(left, top + textarea, right - left)
        love.graphics.printf("YOUR CLONES WILL INCUBATE FOR " .. self.choice .. " nanoseconds", left, top + textarea * 3, right - left)

        self.btn.ok:draw(left, top + textarea * 4, 150)
        self.btn.cancel:draw(left + 200, top + textarea * 4, 150)
    elseif self.incubate_timer < INCUBATE_TIME then
        local text = "Incubating"
        for i=1,self.incubate_timer * 10 do
            text = text .. "."
        end
        love.graphics.printf(text, left, top, right - left)
    else
        love.graphics.printf("SELECT A BODY", left, top, right - left)

        local box_width = 220
        local box_height = box_width * 1.5
        local box_padding = 0
        self.body_box[1] = {left + box_padding, top + textarea, box_width, box_height}
        self.body_box[2] = {sw / 2 - box_width /2, top + textarea, box_width, box_height}
        self.body_box[3] = {right - box_width - box_padding, top + textarea, box_width, box_height}

        for i, box in ipairs(self.body_box) do
            ui.drawBox(box[1], box[2], box[3], box[4], color.win_bg, color.win_font)
            love.graphics.draw(assets.gfx.guy_icon, box[1] + 30, box[2], 0, 9, 9)

            -- Draw stats for this body
            local stat_x = box[1]
            local stat_y = box[2] + box_height / 2
            local stat_w = 105
            local stat_h = 20
            local j = 0
            for name, stat in pairs(self.mutated_stats[i]) do
                rprint(string.upper(name), stat_x, stat_y + stat_h * j, stat_w)
                ui.drawBar(stat_x + stat_w + 10, stat_y + stat_h * j, 90, stat / config.max_stat, true)
                j = j + 1
            end
        end
    end
end

function ChamberWindow:update(dt)
    Window.update(self, dt)
    self.incubate_timer = self.incubate_timer + dt

    -- Update slider
    if love.mouse.isDown("l") or love.mouse.isDown("r") then
        self.slider:tryClick(love.mouse.getPosition())
    end

    -- Update internal value
    self.choice = math.floor((1/5) * self.max_slider + 4/5 * self.slider.value * self.max_slider)

    return true
end


function ChamberWindow:mousepressed(x, y)
    -- Check buttons
    if self.choosing then
        if self.btn.cancel:contains(x, y) then self:close(false) end
        if self.btn.ok:contains(x, y) then
            self:mutateStats()
            self.choosing = false
            self.incubate_timer = 0
        end
    elseif self.incubate_timer > INCUBATE_TIME then
        -- Click body box
        for i, box in ipairs(self.body_box) do
            if rect_contains(box[1], box[2], box[1] + box[3], box[2] + box[4], x, y) then
                -- Selected body #i
                for k, v in pairs(self.mutated_stats[i]) do
                    game.player.stats[k] = v
                end
                self:close(true)
            end
        end
    end

    return true
end


function Button:init(text)
    self.text = text
    self.height = 30
end

function Button:draw(x, y, w, h)
    self.x, self.y, self.w = x, y, w
    self.height = self.height or h
    ui.drawBox(self.x, self.y, w, self.height, color.win_button, color.win_font)
    love.graphics.print(self.text, self.x + 10, self.y + self.height / 4)
end

function Button:contains(x, y)
    return rect_contains(self.x, self.y, self.x + self.w, self.y + self.height, x, y)
end


function Slider:init()
    self.value = 0.5
    self.height = 80
    self.x, self.y, self.w = 0, 0, 0
end

function Slider:draw(x, y, w)
    self.x, self.y, self.w = x, y, w

    color.win_button()
    love.graphics.line(self.x, self.y + self.height / 2, self.x + w, self.y + self.height / 2)

    color.win_font()
    local handle_x = self.x + self.w * self.value
    love.graphics.rectangle("fill", handle_x, self.y, self.height / 3, self.height)
end

function Slider:tryClick(x, y)
    if rect_contains(self.x, self.y, self.x + self.w, self.y + self.height, x, y) then
        self.value = (x - self.x) / self.w
    end
end
