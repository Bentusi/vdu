local lv = require("lvgl")

local Valve = {}

-- 元数据，编辑器将读取此表生成属性面板
Valve.__widget_meta = {
    id = "valve",
    name = "Valve",
    description = "旋转阀门控件，可设置角度与尺寸",
    schema_version = "1.0",
    version = "1.0",
    properties = {
        { name = "x", type = "number", default = 0, label = "X" },
        { name = "y", type = "number", default = 0, label = "Y" },
        { name = "size", type = "number", default = 150, label = "尺寸", min = 8, max = 1024 },
        { name = "angle", type = "number", default = 0, label = "角度", min = 0, max = 360 },
        { name = "handle_color", type = "color", default = "#FF5722", label = "把手颜色" },
    },
    events = { "angle_changed" },
}

-- 构造函数：new(parent, props_or_state)
function Valve.new(parent, props)
    props = props or {}
    local self = {}

    -- 初始化属性（使用元数据默认值）
    self.props = {}
    for _, p in ipairs(Valve.__widget_meta.properties) do
        if props[p.name] ~= nil then
            self.props[p.name] = props[p.name]
        else
            self.props[p.name] = p.default
        end
    end

    -- 创建容器
    self.container = lv.obj_create(parent)
    self.container:set_pos(self.props.x, self.props.y)
    self.container:set_size(self.props.size, self.props.size)
    self.container:set_style_radius(lv.RADIUS_CIRCLE, 0)
    self.container:set_style_bg_color(0xE0E0E0, 0)
    self.container:set_style_border_width(2, 0)
    self.container:set_style_border_color(0x606060, 0)
    self.container:remove_flag(lv.OBJ_FLAG_SCROLLABLE)

    -- handle
    self.handle = lv.obj_create(self.container)
    self.handle:set_size(math.floor(self.props.size * 0.7), math.floor(self.props.size * 0.2))
    self.handle:center()
    -- 颜色转换：允许编辑器传入 #RRGGBB 或 hex number
    local function parse_color(c)
        if type(c) == "string" and c:match("^#%x%x%x%x%x%x$") then
            return tonumber(c:sub(2), 16)
        elseif type(c) == "number" then
            return c
        end
        return 0xFF5722
    end
    self.handle:set_style_bg_color(parse_color(self.props.handle_color), 0)
    self.handle:set_style_radius(4, 0)
    self.handle:remove_flag(lv.OBJ_FLAG_SCROLLABLE)

    -- pivot
    self.pivot = lv.obj_create(self.container)
    self.pivot:set_size(math.floor(self.props.size * 0.15), math.floor(self.props.size * 0.15))
    self.pivot:center()
    self.pivot:set_style_radius(lv.RADIUS_CIRCLE, 0)
    self.pivot:set_style_bg_color(0x333333, 0)

    -- 事件监听
    self._event_listeners = { angle_changed = {} }

    -- 实例方法：属性接口
    function self.get_property(_, name)
        return self.props[name]
    end

    function self.set_property(_, name, value)
        self.props[name] = value
        if name == "x" or name == "y" then
            self.container:set_pos(self.props.x, self.props.y)
        elseif name == "size" then
            local s = math.floor(value)
            self.container:set_size(s, s)
            self.handle:set_size(math.floor(s * 0.7), math.floor(s * 0.2))
            self.pivot:set_size(math.floor(s * 0.15), math.floor(s * 0.15))
            self.handle:center()
            self.pivot:center()
        elseif name == "angle" then
            self:set_angle(value)
            -- notify
            for _, cb in ipairs(self._event_listeners.angle_changed) do cb(self, value) end
        elseif name == "handle_color" then
            local c = parse_color(value)
            self.handle:set_style_bg_color(c, 0)
        end
        return true
    end

    function self.get_properties()
        local out = {}
        for k, v in pairs(self.props) do out[k] = v end
        return out
    end

    function self.apply_properties(_, props_table)
        for k, v in pairs(props_table) do
            self:set_property(k, v)
        end
        return true
    end

    function self.to_state()
        return self:get_properties()
    end

    function self.on(_, event_name, callback)
        if not self._event_listeners[event_name] then self._event_listeners[event_name] = {} end
        table.insert(self._event_listeners[event_name], callback)
    end

    -- 旋转函数（使用 LVGL 的样式变换）
    function self.set_angle(_, angle)
        self.props.angle = angle
        if self.handle.set_style_transform_rotation then
            self.handle:set_style_transform_rotation(math.floor(angle * 10), 0)
        end
    end

    function self.get_angle()
        return self.props.angle
    end

    -- 初始化角度
    if self.props.angle then
        self:set_angle(self.props.angle)
    end

    return self
end

return Valve
