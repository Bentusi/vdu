local lv = require("lvgl")
local TrendChart = require("lua.widgets.trend_chart")

-- Get active screen
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

-- Create TrendChart
local chart = TrendChart.new(scr, 50, 50, 700, 300)
    
-- Create a label
local label = lv.label_create(scr)
label:set_text("趋势图演示 (300 点, 1秒刷新)")
label:set_pos(50, 10)
label:set_style_text_font(font_cn, 0)

-- Keep reference to prevent GC
_G.chart = chart
