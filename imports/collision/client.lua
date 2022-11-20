local GetEntityCoords = GetEntityCoords
local DoesEntityExist = DoesEntityExist

local collisionBase = {}
collisionBase.__index = collisionBase

function collisionBase.new(options)
	local self = {}
	self.relevant = {
		entities = {},
		players = {}
	}
	self.tickRate = options.tickRate or 200
	self.bDebug = options.bDebug or false
	self.color = { r = 0, g = 0, b = 255, a = 100 }
	return self
end

function collisionBase:addRelevantEntity(entity)
	if not (DoesEntityExist(entity)) then return end
	if (self:isEntityRelevant(entity)) then return end
	self.relevant.entities[entity] = {
		type = "entity",
		entity = entity,
		bInside = false
	}
end

function collisionBase:removeRelevantEntity(entity)
	if not (self:isEntityRelevant(entity)) then return end
	self.relevant.entities[entity] = nil
end

function collisionBase:isEntityRelevant(entity)
	return self.relevant.entities[entity] ~= nil
end

function collisionBase:clearRelevantEntities()
	self.relevant.entities = {}
end

function collisionBase:getRelevantEntities()
	return self.relevant.entities
end

function collisionBase:addRelevantPlayer(player)
	if (self:isPlayerRelevant(player)) then return end
	self.relevant.players[player] = {
		type = "player",
		player = player,
		bInside = false
	}
end

function collisionBase:removeRelevantPlayer(player)
	if not (self:isPlayerRelevant(player)) then return end
	self.relevant.players[player] = nil
end

function collisionBase:isPlayerRelevant(player)
	return self.relevant.players[player] ~= nil
end

--[[ Sphere ]]
collisionSphere = {}
collisionSphere.__index = collisionSphere
setmetatable(collisionSphere, collisionBase)

function self.createSphere(options)
	if not (options.radius) then return end
	if (options.coords) then
		options.position = options.coords
	end
	if not (options.position) then return end
	local self = setmetatable(collisionBase.new(options), collisionSphere)
	self.type = "sphere"
	self.radius = options.radius or 1.0
	self.position = vector3(options.position.x, options.position.y, options.position.z)

	self.onTick = cslib.onTick(function()
		for key, _ in pairs(self.relevant) do
			local values = self.relevant[key]
			for _, value in pairs(values) do
				if (key == "players") then
					value.entity = GetPlayerPed(value.player)
				end
				if (DoesEntityExist(value.entity)) then
					value.coords = GetEntityCoords(value.entity)
					local bInside = self:isPointInside(value.coords)
					if (bInside) then
						if not (value.inside) then
							value.inside = true
							if (self.onEnter) then
								self:onEnter(value)
								if (self.nearby) then
									value.interval = cslib.setInterval(function()
										self:nearby(value)
									end)
								end
							end
						end
					else
						if (value.inside) then
							value.inside = false
							if (self.onExit) then
								if (self.nearby) then
									if (value.interval) then
										cslib.clearInterval(value.interval)
										value.interval = nil
									end
								end
								self:onExit(value)
							end
						end
					end
				else
					self:removeRelevantEntity(value.entity)
				end
			end
		end
	end)

	if (self.debugThread and self.bDebug) then
		self:debugThread()
	end

	return self
end

function collisionSphere:destroy()

	if (self.interval) then
		cslib.clearInterval(self.interval)
		self.interval = nil
	end

	for key, _ in pairs(self.relevant) do
		local values = self.relevant[key]
		for _, value in pairs(values) do
			if (self.onExit) and (self.nearby) and (value.interval) then
				cslib.clearInterval(value.interval)
				value.interval = nil
			end
		end
	end
end

function collisionSphere:isPointInside(coords)
	local distance = #(vec(coords.x, coords.y, coords.z) - self.position)
	return (distance <= self.radius)
end

function collisionSphere:debugThread()
	local drawSize = self.radius
	cslib.setInterval(function()
		DrawMarker(28, self.position.x, self.position.y, self.position.z, 0, 0, 0, 0, 0, 0, drawSize, drawSize, drawSize, self.color.r, self.color.g, self.color.b, self.color.a, false, false, 0, false, nil, nil, false)
	end, 0)
end
