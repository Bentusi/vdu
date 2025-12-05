local Class = require("lua.core.class")
local lv = require("lvgl")

local TrendChart = Class.new("TrendChart")

-- Constants
local CHART_TYPE_LINE = 1
local CHART_UPDATE_MODE_SHIFT = 0
local CHART_AXIS_PRIMARY_Y = 0

function TrendChart:ctor(parent, x, y, w, h)
    self.chart = lv.chart_create(parent)
    self.chart:set_pos(x, y)
    self.chart:set_size(w, h)
    self.chart:set_type(CHART_TYPE_LINE)
    self.chart:set_point_count(300)
    self.chart:set_update_mode(CHART_UPDATE_MODE_SHIFT)
    self.chart:set_div_line_count(3, 0) -- 3 horizontal division lines, 0 vertical

    -- Add a series
    self.series = self.chart:add_series(0x2196F3, 0) -- Blue color, primary Y axis

    -- Set range (0-100)
    self.chart:set_range(CHART_AXIS_PRIMARY_Y, 0, 100)

    -- Timer for updates
    self.timer = lv.timer_create(function()
        self:update()
    end, 1000) -- 1000ms = 1s
end

function TrendChart:update()
    -- Generate random value between 0 and 100
    local val = math.random(0, 100)
    self.chart:set_next_value(self.series, val)
end

function TrendChart:stop()
    if self.timer then
        lv.timer_delete(self.timer)
        self.timer = nil
    end
end

return TrendChart
