function self.getEntitiesByTypes(types)
    local entities = {}
    local count = 0

    for i = 1, #types, 1 do
        local poolType = types[i]
        local pool = {}

        if (poolType == "CObject") then
            pool = self.getObjects()
        end

        if (poolType == "CPed") then
            pool = self.getPeds()
        end

        if (poolType == "CVehicle") then
            pool = self.getVehicles()
        end

        if (poolType == "CPlayerPed") then
            pool = self.getPlayerPeds()
        end

        for i = 1, #pool, 1 do
            count += 1
            entities[count] = pool[i]
        end
    end

    return entities
end

function self.getPlayerPeds()
    local players = cslib.bIsServer and self.getPlayers() or GetActivePlayers()
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
