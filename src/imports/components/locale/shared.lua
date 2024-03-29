local defaultLang = "en"
local dictionary = {}

local function load(lang)
    assert(lang ~= nil, "lang must be a string")
    assert(type(lang) == "string", "lang must be a string")
    local locales = json.decode(LoadResourceFile(lib.resource.name, ("locales/%s.json"):format(lang)))
    local dict = {}
    if (locales) then
        for locale_id, locale in pairs(locales) do
            if (type(locale_id) == "string" and type(locale) == "string") then
                dict[locale_id] = locale
            else
                print(("invalid locale string for %s: %s"):format(lang, locale_id))
            end
        end
    else
        print(("'locales/%s.json' was not exist"):format(lang))
    end
    dictionary[lang] = dict
end

local string_gsub = string.gsub

local locale
locale = function(string, vars, lang)
    lang = lang or defaultLang
    local langDict = dictionary[lang]
    if not (langDict) then
        load(lang)
        return locale(string, vars, lang)
    end
    local localeString = langDict[string]
    if not (localeString) then
        return ("\"%s\" was not found in the \"%s\" dictionary"):format(string, lang)
    end
    if (vars) then
        localeString = string_gsub(localeString, "%${([%w_]+)}", vars)
    end
    return localeString
end

local function setLanguage(lang)
    assert(lang ~= nil, "lang must be a string")
    assert(type(lang) == "string", "lang must be a string")
    defaultLang = lang
end

cslib_component = setmetatable({
    setLanguage = setLanguage,
    loc = locale,
}, {
    __call = function(_, ...)
        return locale(...)
    end,
})
