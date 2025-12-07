local lv = require("lvgl")
local Valve = require("lua.widgets.valve")

-- Get active screen
local scr = lv.scr_act()
local font_cn = nil
if lv.font_load then
    font_cn = lv.font_load("simhei.ttf", 24)
end
if not font_cn then
    font_cn = lv.font_source_han_sans_sc_16_cjk
end

-- Title
local title = lv.label_create(scr)
title:set_text("动态阀门图示")
title:align(lv.ALIGN_TOP_MID, 0, 20)
title:set_style_text_font(font_cn, 0)

-- Create Valve using new API (props table)
local valve = Valve.new(scr, { x = 0, y = 0, size = 150, angle = 0 })
valve.container:center()

-- Status Label
local label = lv.label_create(scr)
label:set_text("开启")
label:align(lv.ALIGN_BOTTOM_MID, 0, -50)
label:set_style_text_font(font_cn, 0)

-- 当角度变化时更新状态标签（展示 on 事件用法）
valve:on("angle_changed", function(_, angle)
    if angle == 0 then
        label:set_text("关闭")
    elseif angle == 90 then
        label:set_text("开启")
    else
        label:set_text((angle > 45 and "开启中... " or "关闭中... ") .. math.floor(angle) .. " °")
    end
end)

-- Animation state
local target_angle = 90
local current_angle = valve:get_property("angle") or 0
local step = 2

-- Timer to animate valve using set_property 接口
local timer = lv.timer_create(function()
    if current_angle < target_angle then
        current_angle = current_angle + step
        if current_angle > target_angle then current_angle = target_angle end
    elseif current_angle > target_angle then
        current_angle = current_angle - step
        if current_angle < target_angle then current_angle = target_angle end
    else
        if target_angle == 90 then target_angle = 0 else target_angle = 90 end
    end

    valve:set_property("angle", current_angle)
end, 100)

-- Keep reference to prevent GC
_G.valve_demo_timer = timer
_G.valve = valve
