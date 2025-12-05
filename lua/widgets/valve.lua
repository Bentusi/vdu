local Class = require("lua.core.class")
local lv = require("lvgl")

local Valve = Class.new("Valve")

function Valve:ctor(parent, x, y, size)
    -- Container (Valve Body)
    self.container = lv.obj_create(parent)
    self.container:set_pos(x, y)
    self.container:set_size(size, size)
    self.container:set_style_radius(lv.RADIUS_CIRCLE, 0)
    self.container:set_style_bg_color(0xE0E0E0, 0) -- Light gray
    self.container:set_style_border_width(2, 0)
    self.container:set_style_border_color(0x606060, 0)
    self.container:remove_flag(lv.OBJ_FLAG_SCROLLABLE)

    -- Handle (The rotating part)
    -- We use a container for the handle to make it easy to shape
    self.handle = lv.obj_create(self.container)
    self.handle:set_size(math.floor(size * 0.7), math.floor(size * 0.2))
    self.handle:center()
    self.handle:set_style_bg_color(0xFF5722, 0) -- Deep Orange
    self.handle:set_style_radius(4, 0)
    self.handle:remove_flag(lv.OBJ_FLAG_SCROLLABLE)
    
    -- Add a center pivot point visual
    self.pivot = lv.obj_create(self.container)
    self.pivot:set_size(math.floor(size * 0.15), math.floor(size * 0.15))
    self.pivot:center()
    self.pivot:set_style_radius(lv.RADIUS_CIRCLE, 0)
    self.pivot:set_style_bg_color(0x333333, 0)
    
    self.angle = 0
end

-- Set rotation angle in degrees (0-360)
function Valve:set_angle(angle)
    self.angle = angle
    -- LVGL rotation unit is 0.1 degree
    -- 0 is default state
    self.handle:set_style_transform_rotation(math.floor(angle * 10), 0)
end

function Valve:get_angle()
    return self.angle
end

-- Animate to a specific angle
-- Note: This is a simple step-based animation if called in a loop, 
-- or we could implement a timer-based animation here.
-- For now, we just set the angle.
function Valve:animate_to(target_angle)
    self:set_angle(target_angle)
end

return Valve
