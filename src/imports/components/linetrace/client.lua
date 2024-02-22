local function linetrace(startPos, endPos, flags, entity, p8)
    startPos = vec(startPos.x, startPos.y, startPos.z)

    endPos = vec(endPos.x, endPos.y, endPos.z)

    flags = flags or 511

    entity = entity or 0 -- what is this ?

    -- p8 = p8 -- ???

    local handle = StartShapeTestLosProbe(startPos.x, startPos.y, startPos.z, endPos.x, endPos.y, endPos.z, flags, entity, p8)

    repeat
        Wait(0)
        local retval, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(handle)
        if (retval == 2) then
            local returnProps = {
                hit = hit,
                endCoords = vec(endCoords.x, endCoords.y, endCoords.z),
                surfaceNormal = vec(surfaceNormal.x, surfaceNormal.y, surfaceNormal.z),
                materialHash = materialHash,
                entityHit = entityHit,
            }
            return returnProps
        end
    until false
end

cslib_component = lib.promise.warp(linetrace)
