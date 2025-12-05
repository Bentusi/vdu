local lv = require("lvgl")
local TrendChart = require("lua.widgets.trend_chart")

-- Get active screen
local scr = lv.scr_act()

-- Create TrendChart
local chart = TrendChart.new(scr, 50, 50, 700, 300)

-- Create a label
local label = lv.label_create(scr)
label:set_text("Trend Chart Demo (300 points, 1s refresh)")
label:set_pos(50, 10)

-- Keep reference to prevent GC
_G.chart = chart
