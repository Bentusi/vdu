local lv = require("lvgl")
local CustomButton = require("lua.widgets.custom_button")

-- 获取当前活动屏幕
local scr = lv.scr_act()

-- 尝试获取中文字体
-- 使用动态加载的字体
-- 请确保 A:/home/wei/vdu/assets/SimHei.ttf 存在 (或者修改为实际路径)
-- 注意：LVGL 文件系统驱动配置为 'A'，对应根目录 '/' (如果配置为 LV_FS_STDIO_LETTER 'A')
-- 实际上，如果 LV_FS_STDIO_LETTER 是 'A'，那么 A:/path/to/file 会映射到 /path/to/file
-- 如果没有字体文件，请先下载一个 .ttf 文件到项目目录
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
