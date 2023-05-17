local function getObjects()
    return GetAllObjects()
end

local function getPeds()
    return GetAllPeds()
end

local function getVehicles()
    return GetAllVehicles()
end

local function getPlayers()
    return GetPlayers()
end


cslib_component.getObjects = getObjects
cslib_component.getPeds = getPeds
cslib_component.getVehicles = getVehicles
cslib_component.getPlayers = getPlayers
