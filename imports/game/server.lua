function self.getObjects()
    return GetAllObjects()
end

function self.getPeds()
    return GetAllPeds()
end

function self.getVehicles()
    return GetAllVehicles()
end

function self.getEntitiesByTypes(types)
    local entities = {}
    local count = 0

    for i = 1, #types, 1 do
        local poolType = types[i]
        local pool = {}

        if poolType == "CObject" then
            pool = self.getObjects()
        end
        
        if poolType == "CPed" then
            pool = self.getPeds()
        end
        
        if poolType == "CVehicle" then
            pool = self.getVehicles()
        end

        for i = 1, #pool, 1 do
            count += 1
            entities[count] = pool[i]
        end
    end

    return entities
end
