local function getEntitiesByTypes(types)
    local entities = {}
    local count = 0

    for i = 1, #types, 1 do
        local poolType = types[i]
        local pool = {}

        if (poolType == "CObject") then
            pool = lib.game.getObjects()
        end

        if (poolType == "CPed") then
            pool = lib.game.getPeds()
        end

        if (poolType == "CVehicle") then
            pool = lib.game.getVehicles()
        end

        if (poolType == "CPlayerPed") then
            pool = lib.game.getPlayerPeds()
        end

        for i = 1, #pool, 1 do
            count += 1
            entities[count] = pool[i]
        end
    end

    return entities
end

local function getPlayerPeds()
    local players = lib.bIsServer and lib.game.getPlayers() or GetActivePlayers()
    local peds = {}
    local count = 0
    for i = 1, #players, 1 do
        local ped = GetPlayerPed(players[i])
        if (DoesEntityExist(ped)) then
            count += 1
            peds[count] = ped
        end
    end
    return peds
end

cslib_component.getPlayerPeds = getPlayerPeds
cslib_component.getEntities = function()
    return getEntitiesByTypes({ "CObject", "CPed", "CVehicle" })
end
cslib_component.getEntitiesByTypes = getEntitiesByTypes
