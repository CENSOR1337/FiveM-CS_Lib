local timeSync = {
    time = 0,
    offset = 0,
    isSynced = false,
}

local function syncTime()
    timeSync.isSynced = false
    local start = GetGameTimer()

    lib.resource.callback("sync.server.time", function(serverTime)
        local timeNow = GetGameTimer()
        local responseTime = timeNow - start

        timeSync.time = responseTime + serverTime
        timeSync.offset = timeNow
        timeSync.isSynced = true
    end)
end

syncTime()
local function getServerTime()
    local timeNow = GetGameTimer()
    local timeDiff = timeNow - timeSync.offset
    return timeSync.time + timeDiff
end

cslib_component.getNetTime = getServerTime
cslib_component.isNetTimeSynced = function()
    return timeSync.isSynced
end
