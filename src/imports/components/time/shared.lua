local GetGameTimer = GetGameTimer

local function TimeSince(time)
    return GetGameTimer() - time
end

cslib_component.getTime = GetGameTimer
cslib_component.timeSince = TimeSince
