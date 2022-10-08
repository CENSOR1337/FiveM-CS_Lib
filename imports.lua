--[[ Init ]]
if (not _VERSION:find("5.4")) then error("^1[ Please enable Lua 5.4 ]^0", 2) end
local resourceName = "censor_lib"
local bLibStarted = GetResourceState(resourceName):find("start")
if not (bLibStarted) then error("^1[ Please enable Lua 5.4 ]^0", 2) end

--[[ Imports ]] --
local LoadResourceFile = LoadResourceFile
local bServer = IsDuplicityVersion()

local lib = {}
setmetatable(lib, {
    __index = function(t, k)
        local source = ""
        local shared = LoadResourceFile(resourceName, ("imports/%s/shared.lua"):format(k))
        if (bServer) then
            source = LoadResourceFile(resourceName, ("imports/%s/server.lua"):format(k))
        else
            source = LoadResourceFile(resourceName, ("imports/%s/client.lua"):format(k))
        end
        if not (shared or source) then error(("^1[ Module \"%s\" not found ]^0"):format(k), 2) end
        source = ("%s\n%s\nreturn self"):format(shared, source)
        local f, error = load(source)
        if not (error) and (f) then
            t[k] = f()
        end
        return t[k]
    end
})

_ENV.cslib = lib