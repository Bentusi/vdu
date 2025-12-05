-- 简单的 Lua 类实现
local Class = {}

function Class.new(name, super)
    local cls = {}
    cls.__cname = name
    cls.__index = cls
    cls.super = super

    if super then
        setmetatable(cls, {__index = super})
    end

    function cls.new(...)
        local instance = setmetatable({}, cls)
        if instance.ctor then
            instance:ctor(...)
        end
        return instance
    end

    return cls
end

return Class
