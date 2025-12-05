# 基于 LVGL 与 Lua 的显示模拟与组态软件技术方案

## 1. 项目概述
构建基于 LVGL 图形库的显示模拟软件，通过嵌入 Lua 脚本引擎实现业务逻辑与界面布局的动态化。软件支持通过 Lua 脚本调用 LVGL API，利用 Lua 的面向对象特性封装复杂控件，并提供图形化的拖拽组态功能。

## 2. 总体架构设计

系统自下而上分为四层：
1.  **基础层 (Native Layer)**: 包含 OS (Linux/Windows)、SDL2 (用于 PC 端模拟显示与输入)、LVGL 核心库、Lua 虚拟机 (5.4)。
2.  **胶水层 (Binding Layer)**: 负责 Lua 与 C 语言的交互，将 LVGL 的 C API 映射为 Lua 函数，并处理内存管理与回调机制。
3.  **框架层 (Framework Layer)**: 使用 Lua 编写的面向对象封装库，提供更高级的控件抽象（Widget Class）。
4.  **应用与组态层 (App & Designer Layer)**: 用户编写的 Lua 业务脚本，以及内置的图形化组态编辑器。

## 3. 核心模块详细设计

### 3.1 胶水层 (Lua Binding for LVGL)
这是连接 Lua 与 LVGL 的桥梁。
*   **对象映射 (Object Mapping)**:
    *   使用 Lua 的 `userdata` 存储 LVGL 的对象指针 (`lv_obj_t*`)。
    *   为 `userdata` 设置 `metatable`，实现面向对象调用风格（如 `btn:set_pos(10, 10)`）。
*   **API 封装**:
    *   **构造函数**: 如 `lv.btn_create(parent)` 返回一个 Lua userdata。
    *   **属性设置**: 封装 `lv_obj_set_x`, `lv_obj_set_style_bg_color` 等。
*   **回调处理 (Callback Handling)**:
    *   LVGL 的事件回调是 C 函数指针。需要编写一个通用的 C 桩函数 (Trampoline)，该函数从 `lv_obj_t` 的 `user_data` 中取出对应的 Lua 函数引用并执行。
*   **内存管理**:
    *   需要处理好 Lua GC 与 LVGL 对象生命周期的关系。建议采用“Lua 引用持有”策略，当 Lua 对象被 GC 时，触发 `__gc` 元方法调用 `lv_obj_delete`（需注意父子关系导致的重复删除问题，通常由 LVGL 管理子对象生命周期，Lua 仅作为句柄）。

### 3.2 Lua 面向对象框架 (Lua OOP)
利用 Lua 的 table 和 metatable 机制实现类与继承。
*   **基类 (Widget)**: 封装所有 LVGL 对象共有的方法（位置、大小、样式）。
*   **复杂控件 (Composite Widgets)**:
    *   利用闭包或类继承，将多个基础 LVGL 控件组合。
    *   例如 `MyGauge` 类可以包含一个 `lv_arc` 和一个 `lv_label`。
    *   对外暴露统一接口（如 `setValue`），内部协调更新各个子控件。

### 3.3 虚拟机与模拟器运行时 (VM & Runtime)
*   **初始化流程**:
    1.  初始化 SDL2 窗口与输入驱动。
    2.  初始化 LVGL 核心。
    3.  初始化 Lua 虚拟机 (`luaL_newstate`)。
    4.  注册 LVGL 绑定库 (`luaopen_lvgl`)。
    5.  加载并运行入口脚本 (`main.lua`)。
*   **主循环 (Main Loop)**:
    ```c
    while(!quit) {
        lv_timer_handler(); // LVGL 任务处理
        process_sdl_events(); // 鼠标/键盘输入传递给 LVGL
        usleep(5000);
    }
    ```

### 3.4 图形化组态功能 (Graphical Designer)
为了实现“拖拽方式实现功能控件组合”，建议在模拟器内部实现一个**编辑模式 (Edit Mode)**。
*   **实现方式**:
    *   利用 LVGL 本身的功能，当进入编辑模式时，为所有控件添加 `LV_OBJ_FLAG_CLICKABLE` 和 `LV_OBJ_FLAG_PRESS_LOCK`，并拦截拖拽事件 (`LV_EVENT_PRESSING`) 来修改控件坐标。
    *   **组件库面板**: 在屏幕侧边显示一个列表，点击或拖出可创建新控件。
    *   **属性编辑器**: 点击控件后，弹出一个属性配置窗口（也是用 LVGL 绘制），修改 Lua 对象的属性。
*   **序列化 (Serialization)**:
    *   编辑完成后，遍历当前的控件树。
    *   将控件的类型、坐标、样式属性导出为 Lua 表或 JSON 格式。
    *   保存为 `.lua` 布局文件，供运行时加载。

## 4. 交互方式与工作流

1.  **启动**: 运行模拟器 `vdu_sim`。
2.  **加载**: 模拟器读取 `config.lua`，构建界面。
3.  **编辑**: 点击“编辑”按钮，进入组态模式。
    *   从工具栏拖拽“按钮”、“仪表盘”到画布。
    *   设置属性（颜色）。
4.  **保存**: 点击保存，生成 `layout_gen.lua`。
5.  **运行**: 退出编辑模式，界面响应交互逻辑。

## 5. 目录结构建议
```
/
├── src/              # C/C++ 源码 (Main, Bindings)
├── lua/              # Lua 源码
│   ├── core/         # OOP 基础类
│   ├── widgets/      # 自定义控件类
│   └── main.lua      # 入口脚本
├── lvgl/             # LVGL 库
└── build/            # 编译输出
```
## 6.依赖
1. apt install libsdl2-dev make