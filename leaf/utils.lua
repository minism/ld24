--[[

#########################################################################
#                                                                       #
# utils.lua                                                             #
#                                                                       #
# Utility functions                                                     #
#                                                                       #
# Copyright 2011 Josh Bothun                                            #
# joshbothun@gmail.com                                                  #
# http://minornine.com                                                  #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License <http://www.gnu.org/licenses/> for         #
# more details.                                                         #
#                                                                       #
#########################################################################                                             

--]]

require 'math'

function leaf.snap_floor(value, step)
    return math.floor(value / step) * step
end

function leaf.snap_ceil(value, step)
    return math.ceil(value / step) * step
end

-- Check if an object is an instance of its prototype
function leaf.isinstance(obj, class)
    return getmetatable(obj) == class
end

-- Like underscore extend but doesnt extend in place
function leaf.extend(...)
    local result = {}
    for i, table in ipairs(arg) do
        for k, v in pairs(table) do
            result[k] = v
        end
    end
    return result
end


-- Return a list of quads for each frame of an image
function leaf.build_quads(image, framewidth, frameheight, x_spacing, y_spacing)
    local quads = {}
    local x_spacing = x_spacing or 0
    local y_spacing = y_spacing or 0
    local rows = math.floor(image:getHeight() / frameheight) - x_spacing
    local cols = math.floor(image:getWidth() / framewidth) - y_spacing
    for j=0, rows - 1 do
        for i=0, cols - 1 do
            local quad = love.graphics.newQuad((i * framewidth) + (i * x_spacing),
                                               (j * frameheight) + (j * y_spacing),
                                               framewidth, frameheight, 
                                               image:getWidth(), image:getHeight())
            table.insert(quads, quad)
        end
    end
    return quads
end
