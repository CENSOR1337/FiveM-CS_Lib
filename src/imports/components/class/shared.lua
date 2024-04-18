local classes = {}
local reservedKeys = lib.set.fromArray({
    "new",
    "destroy",
    "private", -- Reserved for future use
})

function classes.new(...)
    local classObj = {}
    classObj.__index = classObj

    local function createInstance(self, ...)
        local inst = setmetatable({}, classObj)
        inst.__index = inst
        inst.destroyed = false

        if (inst.constructor) then
            inst:constructor(...)
        end

        return inst
    end


    local function destroyInstance(self)
        if not (self) then error("Cannot destroy nil object") end

        if (self.destroyed) then return end

        self.destroyed = true

        if (self.destructor) then
            self:destructor()
        end
    end

    return setmetatable(classObj, {
        __index = function(t, k)
            if (k == "new") then
                return createInstance
            end

            if (k == "destroy") then
                return destroyInstance
            end

            return rawget(t, k)
        end,
        __newindex = function(_, key, value)
            if (reservedKeys:contains(key)) then
                error("Cannot override reserved key: ", key)
            end

            rawset(classObj, key, value)
        end,
    })
end

cslib_component = setmetatable({
    new = classes.new,
}, {
    __call = function(_, ...)
        return classes.new(...)
    end,
})
