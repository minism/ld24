local keys = {
    up = "w",
    left = "a",
    down = "s",
    right = "d",

    a_up = "i",
    a_left = "j",
    a_down = "k",
    a_right = "l",
}

function keys.isDown(command)
    return love.keyboard.isDown(keys[command])
end


return keys