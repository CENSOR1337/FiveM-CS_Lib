local GetGameTimer = GetGameTimer

local function TimeSince(time)
    return GetGameTimer() - time
end

local function timeSinceNet(time)
    return cslib_component.getNetTime() - time
end

cslib_component.getTime = GetGameTimer
cslib_component.timeSince = TimeSince
cslib_component.timeSinceNet = timeSinceNet
