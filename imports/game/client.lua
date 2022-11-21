local _i, _f, _v, _r, _ri, _rf, _rl, _s, _rv, _ro, _in, _ii, _fi = Citizen.PointerValueInt(), Citizen.PointerValueFloat(), Citizen.PointerValueVector(), Citizen.ReturnResultAnyway(), Citizen.ResultAsInteger(), Citizen.ResultAsFloat(), Citizen.ResultAsLong(), Citizen.ResultAsString(), Citizen.ResultAsVector(), Citizen.ResultAsObject2(msgpack.unpack), Citizen.InvokeNative, Citizen.PointerValueIntInitialized, Citizen.PointerValueFloatInitialized

local tostring = tostring
local function _ts(num)
    if num == 0 or not num then
        return nil
    end
    return tostring(num)
end

local GetActivePlayers = GetActivePlayers

function self.getPlayers()
    return GetActivePlayers()
end

function self.getGamePool(poolName)
    return _in(0x2b9d4f50, poolName, _ro)
end

function self.getObjects()
    return self.getGamePool("CObject")
end

function self.getPeds()
    return self.getGamePool("CPed")
end

function self.getVehicles()
    return self.getGamePool("CVehicle")
end

function self.getPlayers()
    local activePlayers = GetActivePlayers()
    local players = {}
    local count = 0
    for i = 1, #activePlayers, 1 do
        count += 1
        players[count] = GetPlayerServerId(activePlayers[i])
    end
    return players
end

function self.getEntities()
    return self.getEntitiesByTypes({ "CObject", "CPed", "CVehicle" })
end

function self.drawText2d(data)
    local text = data.text
    if not (text) then return end
    local offset = data.offset or vec(0.5, 0.5)
    local scale = data.size or 1.0
    local font = data.font or 0
    local color = data.color or { r = 255, g = 255, b = 255, a = 255 }
    local bOutline = data.bOutline or false
    local bCenter = data.bCenter or true
    local bShadow = data.bShadow or false
    local align = data.align or 0

    SetTextFont(font)
    SetTextScale(1, scale)
    SetTextWrap(0.0, 1.0)
    SetTextCentre(bCenter)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextJustification(align)
    SetTextEdge(1, 0, 0, 0, 255)

    if bOutline then
        SetTextOutline()
    end

    if bShadow then
        SetTextDropShadow()
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(offset.x, offset.y)


end

function self.drawText3d(data)
    local text = data.text
    if not (text) then return end
    local coords = data.coords
    if not (coords) then return end
    coords = vec(coords.x, coords.y, coords.z)

    local size = data.size or 1.0
    local font = data.font or 0
    local color = data.color or { r = 255, g = 255, b = 255, a = 255 }
    local bOutline = data.bOutline or false
    local bCenter = data.bCenter or true
    local bShadow = data.bShadow or false

    local camDistance = #(coords - GetFinalRenderedCamCoord())
    local scale = (size / camDistance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(font)
    SetTextProportional(true)
    SetTextColour(color.r, color.g, color.b, color.a)
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(bCenter)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    SetTextEdge(1, 0, 0, 0, 255)

    if (bOutline) then
        SetTextOutline()
    end
    if (bShadow) then
        SetTextDropShadow()
    end
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end
