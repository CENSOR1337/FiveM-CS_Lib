CPlayer = {}
CPlayer.__index = CPlayer
setmetatable(CPlayer, CEntity)

function CPlayer.new(playerId)
    local self = {}
    self.playerId = playerId
    self.entity = GetPlayerPed(playerId)

    local err, errMsg = CEntityValidate(self)
    if (err) then error(errMsg) end

    return setmetatable(self, CPlayer)
end
