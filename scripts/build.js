const Chokidar = require('chokidar');
const fse = require('fs-extra');
const buildConfig = JSON.parse(fse.readFileSync('./build-config.json', 'utf8'));
const luamin = require('lua-format')

buildConfig.output = `${buildConfig.output}${buildConfig.name}/`;

function formatSource(source) {
    let formatted = luamin.Beautify(source, {
        RenameVariables: false,
        RenameGlobals: false,
        SolveMath: false
    })
    return formatted;
}

function buildResource() {
    // list all folders in src/imports/
    const componentsPath = './src/imports/components';
    const components = fse.readdirSync(componentsPath);
    let componentsSource = `local components = {}`;
    components.forEach(component => {
        const filePath = `${componentsPath}/${component}`;

        let sources = [];

        ["shared", "server", "client"].forEach(context => {
            let sourceValid = false;

            if (fse.existsSync(`${filePath}/${context}.lua`)) {
                let content = fse.readFileSync(`${filePath}/${context}.lua`, 'utf8');
                sourceValid = content.length > 0;
            }

            sources.push(sourceValid ? fse.readFileSync(`${filePath}/${context}.lua`, 'utf8') : ``);
        });

        let source = `
        components["${component}"] = function(lib)
            local cslib_component = {}
                ${sources[0]}
            if (lib.bIsServer) then
                ${sources[1]}
            else
                ${sources[2]}
            end
            return cslib_component
        end
        `;
        componentsSource = `${componentsSource}\n${source}`;
    });


    let coreSources = `${fse.readFileSync(`./src/imports/index.lua`, 'utf8')}`;

    componentsSource = `
    ${componentsSource}\n
    local lib = setmetatable({}, {
        __index = function(lib, key)
            local library = components[key]
            if not (library) then
                error(("^1[ Component %s not found ]^0"):format(key), 2)
            end

            rawset(lib, key, library(lib))
            return rawget(lib, key)
        end
    })

    _ENV.cslib = setmetatable({}, {
        __index = function(self, key)

            ${coreSources}

            rawset(_ENV, "cslib", lib)
            return lib[key]
        end
    })`
    let sourceOutput = componentsSource;
    sourceOutput = formatSource(sourceOutput);
    fse.outputFileSync(`./build/imports.lua`, sourceOutput);
    fse.outputFileSync(`${buildConfig.output}/imports.lua`, sourceOutput);
}

Chokidar.watch('./src/').on('change', async (event, path) => {
    buildResource();
});

buildResource();