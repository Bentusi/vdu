local lv = require("lvgl")
local Valve = require("lua.widgets.valve")

-- Get active screen
local scr = lv.scr_act()
local font_cn = nil
if lv.font_load then
    -- 尝试加载当前目录下的 simhei.ttf
    -- 注意：需要使用绝对路径，或者确保工作目录正确
    -- 假设字体文件在 vdu/simhei.ttf
    font_cn = lv.font_load("simhei.ttf", 24)
end

if not font_cn then
    print("警告: 未找到动态加载字体，尝试使用内置字体")
    font_cn = lv.font_source_han_sans_sc_16_cjk
end

-- Title
local title = lv.label_create(scr)
title:set_text("动态阀门图示")
title:align(lv.ALIGN_TOP_MID, 0, 20)
title:set_style_text_font(font_cn, 0)

-- Create Valve
-- Position it in the center
local valve = Valve.new(scr, 0, 0, 150)
valve.container:center()

-- Status Label
local label = lv.label_create(scr)
label:set_text("开启")
label:align(lv.ALIGN_BOTTOM_MID, 0, -50)
label:set_style_text_font(font_cn, 0)

-- Animation state
local target_angle = 90
local current_angle = 0
local step = 2

-- Timer to animate valve
-- This simulates a valve opening and closing continuously
local timer = lv.timer_create(function()
    if current_angle < target_angle then
        current_angle = current_angle + step
        if current_angle > target_angle then current_angle = target_angle end
    elseif current_angle > target_angle then
        current_angle = current_angle - step
        if current_angle < target_angle then current_angle = target_angle end
    else
        -- Wait a bit at the end states? 
        -- For simplicity, we just toggle immediately when reached, 
        -- but maybe we can add a pause logic if needed.
        -- Let's just toggle for continuous movement.
        if target_angle == 90 then
            target_angle = 0
        else
            target_angle = 90
        end
    end
    
    valve:set_angle(current_angle)
    
    if current_angle == 0 then
        label:set_text("关闭")
    elseif current_angle == 90 then
        label:set_text("开启")
    else
        if target_angle == 90 then
             label:set_text("开启中... " .. math.floor(current_angle) .. " °")
        else
             label:set_text("关闭中... " .. math.floor(current_angle) .. " °")
        end
    end
end, 1000) -- Update every 1000ms for smooth animation

-- Keep reference to prevent GC
_G.valve_demo_timer = timer
_G.valve = valve
