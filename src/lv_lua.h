#ifndef LV_LUA_H
#define LV_LUA_H

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "lvgl.h"

int luaopen_lvgl(lua_State *L);

#endif
