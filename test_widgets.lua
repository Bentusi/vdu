
-- Test script for LVGL Lua bindings

function test_widgets()
    print("Testing widget creation...")

    local scr = lvgl.scr_act()
    if not scr then
        print("Error: Failed to get active screen")
        return
    end

    -- Test a few widgets
    local widgets = {
        "button",
        "label",
        "slider",
        "switch",
        "checkbox",
        "bar",
        "arc",
        "arclabel",
        "textarea",
        "dropdown",
        "roller",
        "table",
        "list",
        "win",
        "tabview",
        "tileview",
        "msgbox",
        "spinbox",
        "spinner",
        "calendar",
        "chart",
        "keyboard",
        "led",
        "line",
        "image",
        "imagebutton",
        "spangroup",
        "animimg",
        "canvas",
        "scale",
        "lottie"
    }

    for _, w in ipairs(widgets) do
        local func_name = w .. "_create"
        local func = lvgl[func_name]
        if func then
            print("Creating " .. w .. "...")
            local status, obj = pcall(func, scr)
            if status then
                print("  Success: " .. tostring(obj))
            else
                print("  Failed to create " .. w .. ": " .. tostring(obj))
            end
        else
            print("Error: Function lvgl." .. func_name .. " not found")
        end
    end
    
    print("Widget test completed.")
end

test_widgets()
