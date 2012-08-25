function love.conf(t)
	-- Love settings
	t.title = "ld24"
    t.version = "0.8.0"
	t.author = "joshbothun@gmail.com"
	t.identity = nil
	t.console = true
	t.screen.width = 1024
	t.screen.height = 768
	t.screen.fullscreen = false
	t.screen.vsync = false
	t.screen.fsaa = 0
	
	-- modules
	t.modules.joystick = true
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.image = true
	t.modules.graphics = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true   
	t.modules.physics = false
end

-- Global game config
config = {
	debug = true,
	iso = true,
	scale = 2,
}
