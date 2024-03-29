-- THIS IS STILL WORK IN PROGRESS USE WITH CAUTION

local metaIndex = {}
local isNuiReady = false
local onReadyDispatcher = lib.dispatcher()

function metaIndex.emit(name, ...)
    lib.assertType(name, "string")

    local payload = {
        action = name,
        args = { ... },
    }
    local jsonPayload = json.encode(payload)

    if (isNuiReady) then
        SendNuiMessage(jsonPayload)
        return
    end

    -- Wait for NUI to be ready
    onReadyDispatcher:add(function()
        SendNuiMessage(jsonPayload)
    end)
end

function metaIndex.on(name, listener)
    lib.assertType(name, "string")
    lib.assertType(listener, "function")

    RegisterNuiCallback(name, function(data, cb)
        data = data or {}
        cb(listener(table.unpack(data)) or 1)
    end)
end

function metaIndex.onReady(listener)
    lib.assertType(listener, "function")

    if (isNuiReady) then
        listener()
        return
    end
    onReadyDispatcher:add(listener)
end

function metaIndex.focus(hasFocus, hasCursor)
    SetNuiFocus(hasFocus, hasCursor)
end

function metaIndex.setReady()
    isNuiReady = true
    onReadyDispatcher:broadcast()
end

local nui = setmetatable({}, {
    __index = function(_, k)
        if (k == "isReady") then
            return isNuiReady
        end
        if (k == "isFocus") then
            return IsNuiFocused()
        end
        return metaIndex[k]
    end,
})

cslib_component = nui
