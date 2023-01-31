local function requestAnimDict(animDict, cb)
    if HasAnimDictLoaded(animDict) then return animDict end

    if type(animDict) ~= "string" then
        error(("animDict expected \"string\" (received %s)"):format(type(animDict)))
    end

    if not (cb) then
        error("callback expected \"function\" (received nil)")
    end

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

    if not (model) then
        error("model expected \"string\" or \"number\" (received nil)")
    end

    if not (cb) then
        error("callback expected \"function\" (received nil)")
    end

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

return {
    animDict = {
        request = requestAnimDict,
        requestSync = requestAnimDictSync,
        remove = RemoveAnimDict,
        hasLoaded = HasAnimDictLoaded,
        isValid = DoesAnimDictExist
    },
    model = {
        request = requestModel,
        requestSync = requestModelSync,
        remove = SetModelAsNoLongerNeeded,
        hasLoaded = HasModelLoaded,
        isValid = IsModelValid
    }
}
