--断点列表
local BreakPointTable = {}

--清空断点
local clearBreakPoint = function()
    BreakPointTable = {}
end

local GetFuncInfo = function(infoTable)
    if infoTable == nil then
        return
    end

    local funcInfo =
        string.format(
        "%s_%s_%s_%s",
        infoTable["linedefined"],
        infoTable["lastlinedefined"],
        infoTable["short_src"],
        infoTable["what"]
    )
    return funcInfo
end

local Hookfunc = function(event)
    local hookfunc, mask = debug.gethook()
    local parentFunc = debug.getinfo(2, "S")
    if BreakPointTable == nil then
        return
    end
    local hookfunc, mask = debug.gethook()
    debug.sethook()
    local parentFunc = debug.getinfo(2, "S")
    if parentFunc == nil then
        debug.sethook(hookfunc, mask)
        return
    end
    local info = GetFuncInfo(parentFunc)
    if BreakPointTable[info] == nil then
        debug.sethook(hookfunc, mask)
        return
    end

    --命中次数+1
    BreakPointTable[info][1] = BreakPointTable[info][1] + 1
    if BreakPointTable[info][2] ~= nil and event == "call" then
        BreakPointTable[info][2]()
    end
   
    if BreakPointTable[info][3] ~= nil and (event == "return" or event == "tail return") then
        BreakPointTable[info][3]()
    end 
    debug.sethook(hookfunc, mask)
end

local SetHook = function(func, mask)
    if type(func) ~= "function" then
        return
    end

    local info = debug.getinfo(func, "S")
    if info == nil then
        return
    end

    local funcInfo = GetFuncInfo(info)
    if funcInfo == nil then
        return
    end

    debug.sethook(Hookfunc, mask)
    return funcInfo
end

local LuaGDB = function(func, debugStarFunc, debugEndFunc, ...)
    debug.sethook()
    local args = {...}
    local funcInfo = SetHook(func, "cr")
    if funcInfo == nil then
        return
    end

    if BreakPointTable[funcInfo] == nil then
        BreakPointTable[funcInfo] = {0}
    end
    if type(debugStarFunc) == "function" then
        BreakPointTable[funcInfo][2] =  function()
            debugStarFunc(args)
        end
    end

    if type(debugEndFunc) == "function" then
        BreakPointTable[funcInfo][3] =  function()
            debugEndFunc(args)
        end
    end
end

return {
    LuaGDB = LuaGDB,
    ClearAllBreakPoint = clearBreakPoint
}
