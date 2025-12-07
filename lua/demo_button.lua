local lv = require("lvgl")
local Button = require("lua.widgets.button")

-- 获取当前活动屏幕
local scr = lv.scr_act()

local font_cn = nil
if lv.font_load then font_cn = lv.font_load("simhei.ttf", 24) end
if not font_cn then
    print("无法加载中文字体，使用默认字体")
    font_cn = lv.font_source_han_sans_sc_16_cjk
end

-- 使用新的 Button.new(parent, props) 接口
local btn1 = Button.new(scr, { x = 100, y = 100, width = 200, height = 60, label = "点击我" })
local btn2 = Button.new(scr, { x = 100, y = 200, width = 200, height = 60, label = "重置" })

btn1.label:set_style_text_font(font_cn, 0)
btn2.label:set_style_text_font(font_cn, 0)

-- 注册点击事件（使用规范化的 on(event, cb)）
btn1:on("clicked", function(self)
    print("按钮1被点击了！")
    self:set_property("label", "已点击")
    self:set_property("bg_color", "#E91E63") -- 变为粉色
end)

btn2:on("clicked", function(self)
    print("重置按钮被点击！")
    btn1:set_property("label", "点击我")
    btn1:set_property("bg_color", "#2196F3") -- 变为蓝色
end)

print("Button 演示已加载（使用新 API）")
