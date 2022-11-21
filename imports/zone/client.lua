self.sphere = setmetatable({
    new = function(coords, radius, options)
        local collision = cslib.collision.sphere({
            position = vec(coords.x, coords.y, coords.z),
            radius = radius,
            bDebug = options.bDebug,
            bOnlyRelevant = true
        })
        collision:addRelevantPlayer(PlayerId())
        return sphere
    end
}, {
    __call = function(t, ...)
        return t.new(...)
    end
})
