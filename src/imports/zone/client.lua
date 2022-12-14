self.sphere = setmetatable({
    new = function(coords, radius, options)
        options = options or {}
        options.bOnlyRelevant = true
        local collision = cslib.collision.sphere(coords, radius, options)
        collision:addRelevantPlayer(GetPlayerServerId(PlayerId()))
        return collision
    end
}, {
    __call = function(t, ...)
        return t.new(...)
    end
})
