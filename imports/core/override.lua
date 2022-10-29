local AddEventHandler = AddEventHandler
local RegisterNetEvent = RegisterNetEvent

self.on = AddEventHandler

if (IsDuplicityVersion()) then
    self.onClient = RegisterNetEvent
else
    self.onServer = RegisterNetEvent
end
