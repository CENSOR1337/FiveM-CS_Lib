local function requestAnimDict(animDict, cb)
    lib.assertType(animDict, "string")
    lib.assertType(cb, "function", "table")

    if not DoesAnimDictExist(animDict) then
        error(("animDict \"%s\" was not exist"):format(animDict))
    end

    if (HasAnimDictLoaded(animDict)) then
        cb()
        return
    end

    RequestAnimDict(animDict)

    local interval
    interval = lib.setInterval(function()
        if HasAnimDictLoaded(animDict) then
            if (cb) then
                cb()
            end
            lib.clearInterval(interval)
        end
    end, 100)
end

local function requestAnimDictSync(animDict)
    if not (coroutine.running()) then
        error("This function must be called in a coroutine")
    end

    local p = promise.new()

    requestAnimDict(animDict, function()
        p:resolve(animDict)
    end)

    return Citizen.Await(p)
end

local function requestModel(model, cb)
    lib.assertType(model, "string", "number")
    lib.assertType(cb, "function", "table")

    local modelStr
    if type(model) ~= "number" then
        modelStr = model
        model = joaat(model)
    end

    if not IsModelValid(model) then
        error(("model \"%s\" is not valid"):format(modelStr and modelStr or model))
    end

    if (HasModelLoaded(model)) then
        cb()
        return
    end

    RequestModel(model)

    local interval
    interval = lib.setInterval(function()
        if HasModelLoaded(model) then
            if (cb) then
                cb()
            end
            lib.clearInterval(interval)
        end
    end, 100)
end

local function requestModelSync(model)
    if not (coroutine.running()) then
        error("This function must be called in a coroutine")
    end

    local p = promise.new()

    requestModel(model, function()
        p:resolve(model)
    end)

    return Citizen.Await(p)
end

cslib_component.animDict = {
    request = setmetatable({
        await = requestAnimDictSync,
    }, {
        __call = function(_, ...)
            return requestAnimDict(...)
        end,
    }),
    remove = RemoveAnimDict,
    hasLoaded = HasAnimDictLoaded,
    isValid = DoesAnimDictExist,
}
cslib_component.model = {
    request = setmetatable({
        await = requestModelSync,
    }, {
        __call = function(_, ...)
            return requestModel(...)
        end,
    }),
    remove = SetModelAsNoLongerNeeded,
    hasLoaded = HasModelLoaded,
    isValid = IsModelValid,
}
