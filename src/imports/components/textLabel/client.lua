local TextLabel = {}
TextLabel.__index = TextLabel
local tickPool = cslib.tickPool.new()

function TextLabel.new()
    local self = {}
    self.text = "test"
    self.position = vec(0, 0, 0)
    self.scale = 1.0
    self.fontId = 0
    self.color = { r = 255, g = 255, b = 255, a = 255 }
    self.bOutline = false
    self.bCenter = true
    self.bShadow = false

    self.tickTimer = tickPool:add(function()
        if (self.text == nil) then return end

        local text = self.text
        local coords = vec(self.position.x, self.position.y, self.position.z)
        local scale = self.scale
        local font = self.fontId
        local color = self.color
        local bOutline = self.bOutline
        local bCenter = self.bCenter
        local bShadow = self.bShadow

        local camDistance = #(coords - GetFinalRenderedCamCoord())
        scale = (scale / camDistance) * 2
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
    end)

    return setmetatable(self, TextLabel)
end

function TextLabel:destroy()
    tickPool:remove(self.tickTimer)
end

function TextLabel:setText(text)
    self.text = text
end

function TextLabel:setPosition(position)
    self.position = vec(position.x, position.y, position.z)
end

function TextLabel:setScale(scale)
    self.scale = scale
end

function TextLabel:setFont(fontName)
    self.fontId = RegisterFontId(fontName)
end

function TextLabel:setFontId(fontId)
    self.fontId = fontId
end

-- NOT READY TO USE YET --