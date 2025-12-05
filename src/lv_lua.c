#include "lv_lua.h"
#include "src/libs/tiny_ttf/lv_tiny_ttf.h"
#include <stdio.h>
#include <errno.h>
#include <string.h>

// 中文字体和其他常用字体支持
LV_FONT_DECLARE(lv_font_source_han_sans_sc_16_cjk);
LV_FONT_DECLARE(lv_font_montserrat_14);

// 全局 Lua 状态机指针，用于在 C 回调中访问 Lua 环境
static lua_State *GL = NULL;

/**
 * @brief 辅助函数。检查栈上指定位置是否为有效的 LVGL 对象
 * @param L Lua 状态机
 * @param idx 栈索引
 * @return lv_obj_t* LVGL 对象指针
 */
static lv_obj_t* check_lv_obj(lua_State *L, int idx) {
    lv_obj_t **ud = (lv_obj_t **)luaL_checkudata(L, idx, "lv_obj");
    luaL_argcheck(L, ud != NULL, idx, "lv_obj expected");
    return *ud;
}

/**
 * @brief 辅助函数。将 LVGL 对象指针包装为 Lua userdata
 * @param L Lua 状态机
 * @param obj LVGL 对象指针
 */
static void push_lv_obj(lua_State *L, lv_obj_t *obj) {
    if (obj == NULL) {
        lua_pushnil(L);
        return;
    }
    lv_obj_t **ud = (lv_obj_t **)lua_newuserdata(L, sizeof(lv_obj_t *));
    *ud = obj;
    luaL_getmetatable(L, "lv_obj");
    lua_setmetatable(L, -2);
}

// --- LVGL API 封装 ---
// 宏定义：生成标准创建函数
// 根据 lvgl 提供的控件创建函数，生成对应的 Lua 绑定函数
// lvgl中函数名都如：lv_xxxxx_create
#define DEFINE_LV_CREATE(name) \
static int l_##name##_create(lua_State *L) { \
    lv_obj_t *parent = NULL; \
    if (lua_gettop(L) > 0 && !lua_isnil(L, 1)) { \
        parent = check_lv_obj(L, 1); \
    } else { \
        parent = lv_scr_act(); \
    } \
    push_lv_obj(L, lv_##name##_create(parent)); \
    return 1; \
}

// 标准控件创建函数
DEFINE_LV_CREATE(animimg)
DEFINE_LV_CREATE(arc)
DEFINE_LV_CREATE(arclabel)
DEFINE_LV_CREATE(bar)
DEFINE_LV_CREATE(button)
DEFINE_LV_CREATE(buttonmatrix)
DEFINE_LV_CREATE(calendar)
DEFINE_LV_CREATE(canvas)
DEFINE_LV_CREATE(chart)
DEFINE_LV_CREATE(checkbox)
DEFINE_LV_CREATE(dropdown)
DEFINE_LV_CREATE(image)
DEFINE_LV_CREATE(imagebutton)
DEFINE_LV_CREATE(keyboard)
DEFINE_LV_CREATE(led)
DEFINE_LV_CREATE(line)
DEFINE_LV_CREATE(list)
DEFINE_LV_CREATE(lottie)
DEFINE_LV_CREATE(menu)
DEFINE_LV_CREATE(msgbox)
DEFINE_LV_CREATE(roller)
DEFINE_LV_CREATE(scale)
DEFINE_LV_CREATE(slider)
DEFINE_LV_CREATE(spangroup)
DEFINE_LV_CREATE(spinbox)
DEFINE_LV_CREATE(spinner)
DEFINE_LV_CREATE(switch)
DEFINE_LV_CREATE(table)
DEFINE_LV_CREATE(tabview)
DEFINE_LV_CREATE(textarea)
DEFINE_LV_CREATE(tileview)
DEFINE_LV_CREATE(win)

// lv.scr_act() - 获取当前活动屏幕
static int l_scr_act(lua_State *L) {
    push_lv_obj(L, lv_scr_act());
    return 1;
}

// lv.label_create(parent) - 创建标签
static int l_label_create(lua_State *L) {
    lv_obj_t *parent = NULL;
    if (lua_gettop(L) > 0 && !lua_isnil(L, 1)) {
        parent = check_lv_obj(L, 1);
    } else {
        parent = lv_scr_act();
    }
    push_lv_obj(L, lv_label_create(parent));
    return 1;
}

// obj:set_pos(x, y) - 设置位置
static int l_obj_set_pos(lua_State *L) {
    lv_obj_t *obj = check_lv_obj(L, 1);
    int x = luaL_checkinteger(L, 2);
    int y = luaL_checkinteger(L, 3);
    lv_obj_set_pos(obj, x, y);
    return 0;
}

// obj:set_size(w, h) - 设置大小
static int l_obj_set_size(lua_State *L) {
    lv_obj_t *obj = check_lv_obj(L, 1);
    int w = luaL_checkinteger(L, 2);
    int h = luaL_checkinteger(L, 3);
    lv_obj_set_size(obj, w, h);
    return 0;
}

// obj:center() - 居中
static int l_obj_center(lua_State *L) {
    lv_obj_t *obj = check_lv_obj(L, 1);
    lv_obj_center(obj);
    return 0;
}

// obj:set_style_bg_color(color_hex) - 设置背景颜色
static int l_obj_set_style_bg_color(lua_State *L) {
    lv_obj_t *obj = check_lv_obj(L, 1);
    uint32_t c = luaL_checkinteger(L, 2);
    lv_obj_set_style_bg_color(obj, lv_color_hex(c), 0);
    return 0;
}

// label:set_text(text) - 设置标签文本
static int l_label_set_text(lua_State *L) {
    lv_obj_t *obj = check_lv_obj(L, 1);
    const char *text = luaL_checkstring(L, 2);
    lv_label_set_text(obj, text);
    return 0;
}

// obj:set_style_text_font(font, selector) - 设置字体
static int l_obj_set_style_text_font(lua_State *L) {
    lv_obj_t *obj = check_lv_obj(L, 1);
    if (!lua_islightuserdata(L, 2)) {
        return luaL_error(L, "font expected (lightuserdata)");
    }
    const lv_font_t *font = (const lv_font_t *)lua_touserdata(L, 2);
    lv_style_selector_t selector = 0; 
    if (lua_gettop(L) >= 3) {
        selector = (lv_style_selector_t)luaL_checkinteger(L, 3);
    }
    lv_obj_set_style_text_font(obj, font, selector);
    return 0;
}

// slider/bar:set_value(value, anim)
static int l_bar_set_value(lua_State *L) {
    lv_obj_t *obj = check_lv_obj(L, 1);
    int32_t value = luaL_checkinteger(L, 2);
    int anim = 0;
    if (lua_gettop(L) >= 3) {
        anim = lua_toboolean(L, 3);
    }
    lv_bar_set_value(obj, value, anim ? LV_ANIM_ON : LV_ANIM_OFF);
    return 0;
}

// tabview:add_tab(name)
static int l_tabview_add_tab(lua_State *L) {
    lv_obj_t *obj = check_lv_obj(L, 1);
    const char *name = luaL_checkstring(L, 2);
    push_lv_obj(L, lv_tabview_add_tab(obj, name));
    return 1;
}

// lv.font_load(path, size) - 加载 TTF 字体
static int l_font_load(lua_State *L) {
    const char *path = luaL_checkstring(L, 1);
    int size = luaL_checkinteger(L, 2);
    
    lv_font_t *font = lv_tiny_ttf_create_file(path, size);
    if (!font) {
        lua_pushnil(L);
        return 1;
    }
    
    // 返回 lightuserdata，注意：这里没有自动内存管理
    // 实际项目中应该使用 full userdata 并绑定 __gc 方法调用 lv_tiny_ttf_destroy
    lua_pushlightuserdata(L, font);
    return 1;
}

// lv.font_free(font) - 释放 TTF 字体
static int l_font_free(lua_State *L) {
    if (!lua_islightuserdata(L, 1)) {
        return luaL_error(L, "font expected (lightuserdata)");
    }
    lv_font_t *font = (lv_font_t *)lua_touserdata(L, 1);
    lv_tiny_ttf_destroy(font);
    return 0;
}

// --- 事件处理 ---

// 通用 C 回调函数，转发事件给 Lua
static void lua_event_cb(lv_event_t * e) {
    if (!GL) return;
    
    // 从 user_data 获取 Lua 回调函数的引用 (registry index)
    // 注意：这里假设 user_data 仅用于存储这个引用
    int ref = (int)(intptr_t)lv_obj_get_user_data(lv_event_get_target(e));
    
    if (ref != 0 && ref != LUA_NOREF) {
        lua_rawgeti(GL, LUA_REGISTRYINDEX, ref); // 获取 Lua 函数
        if (lua_isfunction(GL, -1)) {
            // 调用 Lua 函数: func(obj)
            // 这里可以把 obj 传回去，但为了简单，暂时不传参数，或者只传 obj
            // push_lv_obj(GL, lv_event_get_target(e)); 
            if (lua_pcall(GL, 0, 0, 0) != LUA_OK) {
                printf("Lua Event Error: %s\n", lua_tostring(GL, -1));
                lua_pop(GL, 1);
            }
        } else {
            lua_pop(GL, 1); // 弹出的不是函数
        }
    }
}

// obj:add_clicked_cb(func) - 绑定点击事件
static int l_obj_add_clicked_cb(lua_State *L) {
    lv_obj_t *obj = check_lv_obj(L, 1);
    luaL_checktype(L, 2, LUA_TFUNCTION);
    
    // 将 Lua 函数存入 Registry，获取引用
    lua_pushvalue(L, 2);
    int ref = luaL_ref(L, LUA_REGISTRYINDEX);
    
    // 将引用存入 LVGL 对象的 user_data
    // 注意：这会覆盖之前存储的任何 user_data
    lv_obj_set_user_data(obj, (void*)(intptr_t)ref);
    
    // 添加 LVGL 事件回调
    lv_obj_add_event_cb(obj, lua_event_cb, LV_EVENT_CLICKED, NULL);
    
    return 0;
}

// --- 模块注册 ---

static const luaL_Reg lv_funcs[] = {
    {"scr_act", l_scr_act},
    {"animimg_create", l_animimg_create},
    {"arc_create", l_arc_create},
    {"arclabel_create", l_arclabel_create},
    {"bar_create", l_bar_create},
    {"button_create", l_button_create},
    {"btn_create", l_button_create},
    {"buttonmatrix_create", l_buttonmatrix_create},
    {"calendar_create", l_calendar_create},
    {"canvas_create", l_canvas_create},
    {"chart_create", l_chart_create},
    {"checkbox_create", l_checkbox_create},
    {"dropdown_create", l_dropdown_create},
    {"image_create", l_image_create},
    {"imagebutton_create", l_imagebutton_create},
    {"keyboard_create", l_keyboard_create},
    {"label_create", l_label_create},
    {"led_create", l_led_create},
    {"line_create", l_line_create},
    {"list_create", l_list_create},
    {"lottie_create", l_lottie_create},
    {"menu_create", l_menu_create},
    {"msgbox_create", l_msgbox_create},
    {"roller_create", l_roller_create},
    {"scale_create", l_scale_create},
    {"slider_create", l_slider_create},
    {"spangroup_create", l_spangroup_create},
    {"spinbox_create", l_spinbox_create},
    {"spinner_create", l_spinner_create},
    {"switch_create", l_switch_create},
    {"table_create", l_table_create},
    {"tabview_create", l_tabview_create},
    {"textarea_create", l_textarea_create},
    {"tileview_create", l_tileview_create},
    {"win_create", l_win_create},
    {"font_load", l_font_load},
    {"font_free", l_font_free},
    {NULL, NULL}
};

static const luaL_Reg lv_obj_methods[] = {
    {"set_pos", l_obj_set_pos},
    {"set_size", l_obj_set_size},
    {"center", l_obj_center},
    {"set_style_bg_color", l_obj_set_style_bg_color},
    {"set_style_text_font", l_obj_set_style_text_font},
    {"set_text", l_label_set_text},
    {"set_value", l_bar_set_value},
    {"add_tab", l_tabview_add_tab},
    {"add_clicked_cb", l_obj_add_clicked_cb},
    {NULL, NULL}
};

// 模块入口函数
int luaopen_lvgl(lua_State *L) {
    GL = L; // 保存全局状态机指针
    
    luaL_newmetatable(L, "lv_obj");
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_setfuncs(L, lv_obj_methods, 0);
    
    luaL_newlib(L, lv_funcs);

    // Register fonts
    lua_pushlightuserdata(L, (void*)&lv_font_source_han_sans_sc_16_cjk);
    lua_setfield(L, -2, "font_source_han_sans_sc_16_cjk");

    lua_pushlightuserdata(L, (void*)&lv_font_montserrat_14);
    lua_setfield(L, -2, "font_montserrat_14");

    return 1;
}
