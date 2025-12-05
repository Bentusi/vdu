local Class = require("lua.core.class")
local lv = require("lvgl")

-- 定义 CustomButton 类
local CustomButton = Class.new("CustomButton")

-- 构造函数
function CustomButton:ctor(parent, x, y, w, h, text)
    -- 创建基础按钮
    self.btn = lv.btn_create(parent)
    self.btn:set_pos(x, y)
    self.btn:set_size(w, h)
    
    -- 创建内部标签
    self.label = lv.label_create(self.btn)
    self.label:set_text(text or "Button")
    self.label:center()
    
    -- 默认样式
    self:setColor(0x2196F3) -- 默认蓝色
end

-- 设置颜色方法
function CustomButton:setColor(hex_color)
    self.btn:set_style_bg_color(hex_color)
end

-- 设置文字方法
function CustomButton:setText(text)
    self.label:set_text(text)
    self.label:center() -- 文字改变后重新居中
end

-- 设置字体方法
function CustomButton:setFont(font)
    self.label:set_style_text_font(font, 0)
end

-- 绑定点击事件
function CustomButton:onClick(callback)
    self.btn:add_event_cb(callback, lv.EVENT_CLICKED, nil)
end

return CustomButton
