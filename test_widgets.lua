
-- Test script for LVGL Lua bindings with command line input

function test_widgets()
    local scr = lvgl.scr_act()
    if not scr then
        print("Error: Failed to get active screen")
        return
    end

    -- Check for command line argument
    local widget_name = arg[1]
    
    if not widget_name then
        print("Usage: ./vdu_sim test_widgets.lua <widget_name>")
        print("Available widgets:")
        local widgets = {
            "button", "label", "slider", "switch", "checkbox", "bar", "arc", 
            "arclabel", "textarea", "dropdown", "roller", "table", "list", 
            "win", "tabview", "tileview", "msgbox", "spinbox", "spinner", 
            "calendar", "chart", "keyboard", "led", "line", "image", 
            "imagebutton", "spangroup", "animimg", "canvas", "scale", "lottie"
        }
        for _, w in ipairs(widgets) do
            io.write(w .. " ")
        end
        print("")
        return
    end

    print("Attempting to create widget: " .. widget_name)

    local func_name = widget_name .. "_create"
    local func = lvgl[func_name]

    if func then
        local obj = func(scr)
        if obj then
            print("Successfully created " .. widget_name)
            
            -- Set some common properties to make it visible
            obj:center()
            
            -- Specific setup for some widgets to make them look better
            if widget_name == "label" then
                obj:set_text("Hello " .. widget_name)
            elseif widget_name == "button" then
                local label = lvgl.label_create(obj)
                label:set_text("Button")
                label:center()
            elseif widget_name == "slider" then
                obj:set_size(200, 20)
            elseif widget_name == "switch" then
                -- default size is usually fine
            elseif widget_name == "checkbox" then
                obj:set_text("Check me")
            elseif widget_name == "bar" then
                obj:set_size(200, 20)
                obj:set_value(50, lvgl.ANIM_OFF)
            elseif widget_name == "arc" then
                obj:set_size(150, 150)
                obj:set_value(50)
            elseif widget_name == "textarea" then
                obj:set_text("Type here...")
            elseif widget_name == "dropdown" then
                obj:set_options("Option 1\nOption 2\nOption 3")
            elseif widget_name == "roller" then
                obj:set_options("Item 1\nItem 2\nItem 3", lvgl.ROLLER_MODE_NORMAL)
            elseif widget_name == "table" then
                -- Table needs more setup usually
            elseif widget_name == "list" then
                obj:set_size(180, 220)
                obj:add_text("List Title")
                obj:add_btn(nil, "Item 1")
                obj:add_btn(nil, "Item 2")
            elseif widget_name == "win" then
                -- Win needs header height
                -- obj is already created, but win_create usually takes header height
                -- If binding is simple wrapper, it might just be obj_create
                -- Let's assume standard creation
            elseif widget_name == "tabview" then
                -- Tabview create takes pos and size usually
            elseif widget_name == "calendar" then
                obj:set_size(300, 300)
            elseif widget_name == "keyboard" then
                -- Keyboard usually attaches to a textarea
            elseif widget_name == "chart" then
                obj:set_size(200, 150)
                obj:set_type(lvgl.CHART_TYPE_LINE)
                local s1 = obj:add_series(lvgl.color_hex(0xFF0000), lvgl.CHART_AXIS_PRIMARY_Y)
                obj:set_next_value(s1, 10)
                obj:set_next_value(s1, 50)
                obj:set_next_value(s1, 30)
            end
            
        else
            print("Failed to create object for " .. widget_name)
        end
    else
        print("Error: Unknown widget '" .. widget_name .. "' (function " .. func_name .. " not found)")
    end
end

test_widgets()
