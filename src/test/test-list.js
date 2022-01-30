const compute = require('@google-cloud/compute');
const instancesClient = new compute.InstancesClient({fallback: 'rest'});

async function startInstancePubSub(){
    const project = await instancesClient.getProjectId();
    console.log("Project: project");
    const payload = {
        "zone":"northamerica-northeast1-a", 
        "label":"env=lab"
    }
    const options = {
    filter: `labels.${payload.label}`,
    project,
    zone: payload.zone,
    };
    console.log("options:" + JSON.stringify(options));
    const [instances] = await instancesClient.list(options);
    // console.log("instances:" + JSON.stringify(instances));

    if (instances && instances instanceof Array && instances.length > 0) {
        await Promise.all(
          instances.map(async instance => {
            console.log("Stopping instance: " + instance.name)
            return instancesClient.start({
              project,
              zone: payload.zone,
              instance: instance.name,
            });
          })
        );
    }
}

startInstancePubSub()