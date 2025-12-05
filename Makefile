# Makefile
CC = gcc
CFLAGS = -g -Wall -I. -I./src -I./lvgl-9.4.0 -I./lua-5.4.6/src -D_DEFAULT_SOURCE -D_BSD_SOURCE
LDFLAGS = -lSDL2 -lm -ldl

# Lua
LUA_DIR = lua-5.4.6
LUA_SRC = $(wildcard $(LUA_DIR)/src/*.c)
# Exclude lua.c and luac.c from the library part
LUA_CORE_SRC = $(filter-out $(LUA_DIR)/src/lua.c $(LUA_DIR)/src/luac.c, $(LUA_SRC))
LUA_CORE_OBJ = $(LUA_CORE_SRC:.c=.o)

# LVGL
LVGL_DIR = lvgl-9.4.0
LVGL_DIR_NAME = lvgl-9.4.0
LVGL_PATH = $(shell pwd)/$(LVGL_DIR)
# Include lvgl.mk to get CSRCS
include $(LVGL_DIR)/lvgl.mk

# App
APP_SRC = $(wildcard src/*.c)
APP_OBJ = $(APP_SRC:.c=.o)

# All objects
CXX_OBJ = $(CXXSRCS:.cpp=.o)
LVGL_OBJ = $(CSRCS:.c=.o) $(CXX_OBJ)
OBJ = $(APP_OBJ) $(LUA_CORE_OBJ) $(LVGL_OBJ)

TARGET = vdu_sim

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS) -lstdc++

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.cpp
	g++ $(CFLAGS) -c $< -o $@

clean:
	rm -f $(APP_OBJ) $(TARGET)

dist-clean:
	rm -f $(OBJ) $(TARGET)
