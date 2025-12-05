local lv = require("lvgl")
local CustomButton = require("lua.widgets.custom_button")

-- 获取当前活动屏幕
local scr = lv.scr_act()

-- 尝试获取中文字体
local font_cn = lv.font_source_han_sans_sc_16_cjk
if not font_cn then
    print("警告: 未找到中文字体 lv.font_source_han_sans_sc_16_cjk")
end

-- 创建第一个按钮：演示点击变色和变文字
local btn1 = CustomButton.new(scr, 100, 100, 200, 60, "点击我")
if font_cn then btn1:setFont(font_cn) end

btn1:onClick(function()
    print("按钮1被点击了！")
    btn1:setText("已点击")
    btn1:setColor(0xE91E63) -- 变为粉色
end)

-- 创建第二个按钮：演示重置功能
local btn2 = CustomButton.new(scr, 100, 200, 200, 60, "重置")
if font_cn then btn2:setFont(font_cn) end

btn2:setColor(0x4CAF50) -- 绿色
btn2:onClick(function()
    print("重置按钮被点击！")
    btn1:setText("点击我")
    btn1:setColor(0x2196F3) -- 恢复蓝色
end)

print("CustomButton 演示已加载")
