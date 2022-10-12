--[[ Init ]]
if (not _VERSION:find("5.4")) then error("^1[ Please enable Lua 5.4 ]^0", 2) end
local resourceName = "censor_lib"
local bLibStarted = GetResourceState(resourceName):find("start")
if not (bLibStarted) then error("^1[ Please enable Lua 5.4 ]^0", 2) end

--[[ Imports ]] --
local LoadResourceFile = LoadResourceFile
local bServer = IsDuplicityVersion()

_ENV.__cslib_core = setmetatable({}, {
    __index = function(t, k)
        local source = ""
        local shared = LoadResourceFile(resourceName, ("imports/%s/shared.lua"):format(k))
        if (bServer) then
            source = LoadResourceFile(resourceName, ("imports/%s/server.lua"):format(k))
        else
            source = LoadResourceFile(resourceName, ("imports/%s/client.lua"):format(k))
        end
        if (shared == nil and source == nil) then error(("^1[ Module \"%s\" not found ]^0"):format(k), 2) end
        source = ("local self = __cslib_core\n%s\n%s\nreturn self"):format(shared or "", source or "")
        local f, err = load(source)
        if not (f) or (err) then error(("^1[ Module \"%s\" failed to load ]^0"):format(k), 2) end
        t[k] = f()
        return t[k]
    end
})

_ENV.cslib = _ENV.__cslib_core
