const watcher = require('chokidar').watch;
const fse = require('fs-extra');
const buildConfig = JSON.parse(fse.readFileSync('./build-config.json', 'utf8'));
buildConfig.output = `${buildConfig.output}${buildConfig.name}/`;

let build = () => {
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

watcher('./src/').on('change', async (event, path) => {
    build();
});

build();