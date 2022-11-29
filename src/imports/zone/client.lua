self.sphere = setmetatable({
    new = function(coords, radius, options)
        options = options or {}
        local collision = cslib.collision.sphere({
            position = vec(coords.x, coords.y, coords.z),
            radius = radius,
            bDebug = options.bDebug or false,
            bOnlyRelevant = true
        })
        collision:addRelevantPlayer(GetPlayerServerId(PlayerId()))
        return collision
    end
}, {
    __call = function(t, ...)
        return t.new(...)
    end
})
