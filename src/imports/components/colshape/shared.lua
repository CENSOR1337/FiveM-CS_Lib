local colshape_classWarp = function(class, ...)
    return setmetatable({
        new = class.new,
        classes = class,
    }, {
        __call = function(t, ...)
            return t.new(...)
        end,
    })
end

-- local declaration of native functions
local GetEntityCoords = GetEntityCoords

local ColShape = {}
ColShape.__index = ColShape

function ColShape.new()
    return setmetatable({}, ColShape)
end

function ColShape:isPositionInside(position)
    return false
end

function ColShape:drawDebug()
end

-- start of shpere shape
local ShapeSphere = {}
ShapeSphere.__index = ShapeSphere
setmetatable(ShapeSphere, { __index = ColShape })

function ShapeSphere.new(position, radius)
    lib.validate.type.assert(position, "vector3", "vector4", "table")
    lib.validate.type.assert(radius, "number")

    local self = setmetatable(ColShape.new(), ShapeSphere)
    self.radius = radius
    self.position = vec(position.x, position.y, position.z)
    return self
end

function ShapeSphere:isPositionInside(position)
    local dist = #(position - self.position)
    return (dist <= self.radius)
end

function ShapeSphere:drawDebug()
    local fRadius = self.radius + 0.0
    local color = { r = 0, g = 0, b = 255, a = 75 }
    DrawMarker(28, self.position.x, self.position.y, self.position.z, 0, 0, 0, 0, 0, 0, fRadius, fRadius, fRadius, color.r, color.g, color.b, color.a, false, false, 0, false, nil, nil, false)
end

-- end of sphere shape

local ColshapeBox = {}
ColshapeBox.__index = ColshapeBox
setmetatable(ColshapeBox, { __index = ColShape })

function ColshapeBox.new(position, extent, heading)
    lib.validate.type.assert(position, "vector3", "vector4", "table")
    lib.validate.type.assert(extent, "vector3", "vector4", "table")
    lib.validate.type.assert(heading, "number")

    local self = setmetatable(ColShape.new(), ColshapeBox)
    self.position = vec(position.x, position.y, position.z)
    self.extent = vec(extent.x, extent.y, extent.z)
    self.size = vec(extent.x * 2, extent.y * 2, extent.z * 2)
    self.heading = heading
    return self
end

function ColshapeBox:isPositionInside(position)
    -- Calculate the box's bounds based on the position, size, and extent
    local minBound = self.position - (self.extent)
    local maxBound = self.position + (self.extent)

    -- Check if the position is inside the box
    return position.x >= minBound.x and position.x <= maxBound.x
        and position.y >= minBound.y and position.y <= maxBound.y
        and position.z >= minBound.z and position.z <= maxBound.z
end

function ColshapeBox:drawDebug()
    local color = { r = 0, g = 0, b = 255, a = 75 }
    local minBound = self.position - (self.extent)
    local maxBound = self.position + (self.extent)
    DrawBox(minBound.x, minBound.y, minBound.z, maxBound.x, maxBound.y, maxBound.z, color.r, color.g, color.b, color.a)
end

-- end of box shape

cslib_component.sphere = colshape_classWarp(ShapeSphere)
cslib_component.box = colshape_classWarp(ColshapeBox)
