local table_unpack = table.unpack
local table_pack = table.pack
local CreateThread = Citizen.CreateThread
local CreateThreadNow = Citizen.CreateThreadNow
local CitizenAwait = Citizen.Await

local aliasFields = {
    ["done"] = "after",
    ["then"] = "after", -- i wish i could use this, but it's a reserved keyword
}

local function warpPromise(functionRef)
    return setmetatable({}, {
        __call = function(_, ...)
            local args = { ... }
            local dispatcher = lib.dispatcher()
            local promiseVal

            CreateThreadNow(function()
                promiseVal = table_pack(functionRef(table_unpack(args)))
                dispatcher:broadcast(table_unpack(promiseVal))
            end)

            return setmetatable({
                after = function(callback)
                    lib.assertType(callback, "function")

                    if (promiseVal) then
                        callback(table_unpack(promiseVal))
                        return
                    end

                    dispatcher:add(callback)
                end,

                await = function()
                    if (promiseVal) then
                        return table_unpack(promiseVal)
                    end

                    local p = promise.new()

                    dispatcher:add(function(...)
                        p:resolve({
                            params = { ... },
                        })
                    end)

                    local returnValues = CitizenAwait(p)

                    return table_unpack(returnValues.params)
                end,
            }, {
                __index = function(self, key)
                    local alias = aliasFields[key]
                    if alias then
                        return self[alias]
                    end

                    return rawget(self, key)
                end,
            })
        end,
    })
end

cslib_component.warp = warpPromise
