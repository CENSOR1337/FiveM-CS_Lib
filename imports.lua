--[[ Init ]]
if (not _VERSION:find("5.4")) then error("^1[ Please enable Lua 5.4 ]^0", 2) end
local resourceName = "censor_lib"
local bLibStarted = GetResourceState(resourceName):find("start")
if not (bLibStarted) then error("^1[ Please enable Lua 5.4 ]^0", 2) end

--[[ Imports ]] --
local LoadResourceFile = LoadResourceFile
local bServer = IsDuplicityVersion()

local function initCoreComponent()
    local classSource = ""
    for _, className in ipairs({ "CEntity", "CPed", "CPlayer", "CVehicle" }) do
        local source = LoadResourceFile(resourceName, string.format("imports/core/classes/%s.lua", className))
        if (source) then
            classSource = classSource .. "\n" .. source
        end
    end
    load(classSource)()
    local coreComponents = { "interval", "override", "tick" }
    local coreSource = "local self = {}\n"
    for _, component in ipairs(coreComponents) do
        local source = LoadResourceFile(resourceName, "imports/core/" .. component .. ".lua")
        if (source) then
            coreSource = coreSource .. "\n" .. source
        end
    end
    coreSource = string.format("%s\nreturn self", coreSource)
    return load(coreSource)()
end

_ENV.__cslib_core = setmetatable(initCoreComponent(), {
    __index = function(t, k)
        local source = ""
        local shared = LoadResourceFile(resourceName, ("imports/%s/shared.lua"):format(k))
        if (bServer) then
            source = LoadResourceFile(resourceName, ("imports/%s/server.lua"):format(k))
        else
            source = LoadResourceFile(resourceName, ("imports/%s/client.lua"):format(k))
        end
        if (shared == nil and source == nil) then error(("^1[ Module \"%s\" not found ]^0"):format(k), 2) end
        source = ("local self = {}\n%s\n%s\nreturn self"):format(shared or "", source or "")
        local f, err = load(source)
        if not (f) or (err) then error(("^1[ Module \"%s\" failed to load ]^0"):format(k), 2) end
        rawset(t, k, f())
        return rawget(t, k)
    end
})

_ENV.cslib = _ENV.__cslib_core
