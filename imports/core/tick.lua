local handlers = {}
local handlersList = {}
local handlersLength = 0
local handlerKey = 10
local bReAssignHanlders = false
local bThreadCreated = false
local Wait = Wait

local function reassignHandler()
    table.wipe(handlersList)
    for key, value in pairs(handlers) do
        handlersList[#handlersList + 1] = value
    end
    handlersLength = #handlersList
end

function self.onTick(fnHandler)
    handlerKey += 1
    handlers[handlerKey] = fnHandler
    bReAssignHanlders = true
    if not (bThreadCreated) then
        bThreadCreated = true
        Citizen.CreateThreadNow(function()
            while true do
                for i = 1, handlersLength, 1 do
                    handlersList[i]()
                end
                Wait(0)
                if (bReAssignHanlders) then
                    reassignHandler()
                    bReAssignHanlders = false
                    if (handlersLength <= 0) then
                        bThreadCreated = false
                        break
                    end
                end
            end
        end)
    end

    return handlerKey
end

function self.clearOnTick(key)
    handlers[key] = nil
    bReAssignHanlders = true
end
