## 简易Lua调试工具

可以在目标函数的调用和返回时插入自定义的代码来监视变量。不支持luajit的尾调用监听。

LuaGDB 第一个参数是要监听的函数，第二个和第三个分别是监听函数开始调用时的自定义函数和监听函数返回时自定义函数。