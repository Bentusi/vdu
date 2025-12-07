-- custom_button_example.lua
-- 带元数据的按钮示例，演示如何将属性暴露给编辑器

local Class = require("core.class")
local lv = require("lv")

local Button = {}

Button.__widget_meta = {
  id = "custom_button",
  name = "Custom Button",
  description = "示例按钮，包含 label 与尺寸/位置属性",
  properties = {
    { name = "label", type = "string", default = "OK", label = "文本" },
    { name = "x", type = "number", default = 0, label = "X" },
    { name = "y", type = "number", default = 0, label = "Y" },
    { name = "width", type = "number", default = 120, label = "宽度" },
    { name = "height", type = "number", default = 44, label = "高度" },
    { name = "bg_color", type = "color", default = "#007acc", label = "背景色" },
    { name = "enabled", type = "boolean", default = true, label = "启用" },
  },
  events = { "clicked" },
}

-- new(parent, state)
function Button.new(parent, state)
  state = state or {}
  local self = {}

  -- 初始化属性
  self.props = {}
  for _, p in ipairs(Button.__widget_meta.properties) do
    self.props[p.name] = state[p.name] ~= nil and state[p.name] or p.default
  end

  -- 创建 lv 按钮与标签
  self.obj = lv.btn_create(parent)
  lv.obj_set_size(self.obj, self.props.width, self.props.height)
  lv.obj_set_pos(self.obj, self.props.x, self.props.y)

  self.label = lv.label_create(self.obj)
  lv.label_set_text(self.label, self.props.label)

  -- 简单事件转发：当 lv 发生点击事件时，触发实例回调（编辑器可注册）
  self._event_listeners = {}
  local function evt_cb(e)
    local code = e:get_code() -- 伪代码，取决于绑定实现
    if code == lv.EVENT_CLICKED then
      for _, cb in ipairs(self._event_listeners) do cb(self) end
    end
  end
  -- 如果绑定存在正确的添加事件函数则使用
  if lv.obj_add_event_cb then
    lv.obj_add_event_cb(self.obj, evt_cb, lv.EVENT_CLICKED, nil)
  end

  function self.on(self, event_name, callback)
    if event_name == "clicked" then
      table.insert(self._event_listeners, callback)
    end
  end

  function self.get_property(self, name)
    return self.props[name]
  end

  function self.set_property(self, name, value)
    self.props[name] = value
    if name == "label" then
      lv.label_set_text(self.label, value)
    elseif name == "x" or name == "y" then
      lv.obj_set_pos(self.obj, self.props.x, self.props.y)
    elseif name == "width" or name == "height" then
      lv.obj_set_size(self.obj, self.props.width, self.props.height)
    elseif name == "enabled" then
      if value then lv.obj_clear_state(self.obj, lv.STATE_DISABLED) else lv.obj_add_state(self.obj, lv.STATE_DISABLED) end
    end
    return true
  end

  function self.get_properties(self)
    local out = {}
    for k, v in pairs(self.props) do out[k] = v end
    return out
  end

  function self.apply_properties(self, props_table)
    for k, v in pairs(props_table) do
      self:set_property(k, v)
    end
    return true
  end

  function self.to_state(self)
    return self:get_properties()
  end

  return self
end

return Button
