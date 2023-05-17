--[[
    `network` module will be removed in the future
    Use `net` module instead
 ]]
if (lib.bIsServer) then
    cslib_component.registerServerCallback = lib.net.callback.register
else
    cslib_component.triggerServerCallback = lib.net.callback
    cslib_component.triggerServerCallbackSync = lib.net.callback.await
end
