local isSynced = false
local GetGameTimer = GetGameTimer
local getNetworkedTime = lib.isServer and GetGameTimer or GetNetworkTime

local function TimeSince(time)
    return GetGameTimer() - time
end

local function timeSinceNet(time)
    return getNetworkedTime() - time
end

local function isNetTimeSynced()
    if (isSynced == true) then return true end

    if (lib.isServer) then
        isSynced = true
    else
        isSynced = HasNetworkTimeStarted()
    end

    return isSynced
end

cslib_component.getTime = GetGameTimer
cslib_component.timeSince = TimeSince
cslib_component.isNetTimeSynced = isNetTimeSynced
cslib_component.getNetTime = getNetworkedTime
cslib_component.timeSinceNet = timeSinceNet
