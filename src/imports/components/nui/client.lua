-- THIS IS STILL WORK IN PROGRESS USE WITH CAUTION

local metaIndex = {}
local isNuiReady = false
local onReadyDispatcher = lib.dispatcher()

--[[ JavaScript code for NUI communication

fetch(`https://${GetParentResourceName()}/ON_NUI_READY`, {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify({})
})


class NuiListener {
    eventname;
    listener;

    constructor(eventname, listener) {
        if (typeof eventname !== "string") throw new Error("eventname must be a string");
        if (typeof listener !== "function") throw new Error("listener must be a function");

        this.eventname = eventname;
        this.listener = (event) => {
            const data = event.data;
            if (data.action !== this.eventname) return;
            listener(...data.args || []);
        }

        window.addEventListener("message", this.listener);
    }

    destroy() {
        if (!this.listener) return;
        window.removeEventListener("message", this.listener);
    }
}

class nui {
    static register(eventname, listener) {
        return new NuiListener(eventname, listener);
    }

    static destroy(listener) {
        if (!listener) return;
        listener.destroy();
    }
}

 ]]

function metaIndex.emit(name, ...)
    lib.typeCheck(name, "string")

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
    lib.typeCheck(name, "string")
    lib.typeCheck(listener, "function")

    RegisterNuiCallback(name, function(data, cb)
        cb(listener(data) or {})
    end)
end

function metaIndex.onReady(listener)
    lib.typeCheck(listener, "function")

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

cslib_component.nui = nui
