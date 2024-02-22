local modules = {}

local function export(name, value)
    lib.assertType(name, "string")
    assert(not (modules[name]), ("Component %s already exists"):format(name))
    modules[name] = value
end

local function import(name)
    lib.assertType(name, "string")
    return modules[name]
end

cslib_component.export = export
cslib_component.import = import
