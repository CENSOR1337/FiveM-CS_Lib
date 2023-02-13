--[[
    `network` module will be removed in the future
    Use `net` module instead
 ]]
local library = {}
if (lib.isServer) then
    library.registerServerCallback = lib.net.callback.register
else
    library.triggerServerCallback = lib.net.callback
    library.triggerServerCallbackSync = lib.net.callback.await
end
return library
