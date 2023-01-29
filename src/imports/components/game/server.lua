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

return {
    getObjects = getObjects,
    getPeds = getPeds,
    getVehicles = getVehicles,
    getPlayers = getPlayers,
}
