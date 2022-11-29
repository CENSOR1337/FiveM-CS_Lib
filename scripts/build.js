const Chokidar = require('chokidar');
const fse = require('fs-extra');
const buildConfig = JSON.parse(fse.readFileSync('./build-config.json', 'utf8'));
buildConfig.output = `${buildConfig.output}${buildConfig.name}/`;

function buildResource() {
    fse.removeSync(buildConfig.output, err => {
        if (err) return console.error(err)
        console.log(`${path} removed!`);
    })
    fse.ensureDirSync(buildConfig.output, err => {
        if (err) return console.error(err)
    })

    console.log(`Building ${buildConfig.name}...`);
    buildConfig.works.forEach(work => {
        if (work.action == "copy_folder") {
            fse.copySync(work.source, buildConfig.output + work.output);
            console.log(`${work.source} copied to ${work.output}`);
        }
    });
    console.log("Build complete!");
}

Chokidar.watch('./src/').on('change', async (event, path) => {
    buildResource();
});

buildResource();