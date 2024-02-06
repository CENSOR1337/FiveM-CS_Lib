local GetGameTimer = GetGameTimer

lib.resource.callback.register("sync.server.time", function()
    return GetGameTimer()
end)

cslib_component.getNetTime = GetGameTimer
