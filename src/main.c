#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
#include "lvgl.h"
#include "lv_lua.h"

int main(int argc, char **argv) {
    char *lua_script = NULL;
    // 判断参数传入文件
    if (argc < 2) {
        printf("Usage: %s <lua_script>\n", argv[0]);
        return 1;
    }
    
    lua_script = argv[1];

    lv_init();

    // 使用SDL创建窗口
    // lv_conf.h中将宏 LV_USE_SDL 设置为1
    lv_display_t * disp = lv_sdl_window_create(1024, 768);

    //设置全局字体
    lv_font_t *my_custom_font = lv_tiny_ttf_create_file("simhei.ttf", 24);
    lv_style_t default_style;
    lv_style_init(&default_style);
    lv_style_set_text_font(&default_style, my_custom_font);
    lv_obj_add_style(lv_scr_act(), &default_style, 0);

    lv_group_t * g = lv_group_create();
    lv_group_set_default(g);

    lv_indev_t * mouse = lv_sdl_mouse_create();
    lv_indev_set_group(mouse, g);
    
    lv_indev_t * mousewheel = lv_sdl_mousewheel_create();
    lv_indev_set_group(mousewheel, g);

    lv_indev_t * keyboard = lv_sdl_keyboard_create();
    lv_indev_set_group(keyboard, g);

    // 初始化 Lua 状态机
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    
    // 将 LVGL 模块注册到 Lua
    // lvgl函数定义在 src/lv_lua.c 的 luaopen_lvgl 中
    luaL_requiref(L, "lvgl", luaopen_lvgl, 1);
    lua_pop(L, 1);

    // 运行主脚本
    printf("Loading %s...\n", lua_script);
    if (luaL_dofile(L, lua_script) != LUA_OK) {
        const char *error = lua_tostring(L, -1);
        printf("Lua Error: %s\n", error);
        lua_pop(L, 1);
        lua_close(L);
        return -1;
    }

    // 主循环
    while(1) {
        lv_timer_handler();
        usleep(5000);
    }

    lua_close(L);
    return 0;
}
