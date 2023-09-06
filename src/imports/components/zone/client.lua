cslib_component.sphere = setmetatable({
    new = function(coords, radius, options)
        local zoneObject = {}
        options = options or {}
        local collision = lib.collision.sphere(coords, radius, {
            debug = {
                enabled = options.bDebug or false,
                color = options.color,
            },
        })
        collision.playersOnly = true

        collision:onBeginOverlap(function(other)
            if (other ~= PlayerPedId()) then return end
            if (zoneObject.onBeginOverlap) then
                zoneObject.onBeginOverlap(other)
            end
        end)

        collision:onOverlapping(function(other)
            if (other ~= PlayerPedId()) then return end
            if (zoneObject.onOverlapping) then
                zoneObject.onOverlapping(other)
            end
        end)

        collision:onEndOverlap(function(other)
            if (other ~= PlayerPedId()) then return end
            if (zoneObject.onEndOverlap) then
                zoneObject.onEndOverlap(other)
            end
        end)

        zoneObject.isPointInside = function(self, coords)
            coords = vec(coords.x, coords.y, coords.z)
            return collision:isPositionInside(coords)
        end

        zoneObject.isEntityInside = function(self, entity)
            return collision:isEntityInside(entity)
        end
        
        zoneObject.destroy = function(self)
            collision:destroy()
        end

        zoneObject.setRadius = function(self, radius)
            collision.radius = radius
        end

        zoneObject.getRadius = function(self)
            return collision.radius
        end

        return zoneObject
    end,
}, {
    __call = function(t, ...)
        return t.new(...)
    end,
})
