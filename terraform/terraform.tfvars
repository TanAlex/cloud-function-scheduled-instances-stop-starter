project="th-ttanlab-lab-f7cf07"
region="northamerica-northeast1"
cloud_func_bucket="ttanlab-func-bucket"
cloud_func_service_account = "instance-cloud-func-sa"
cloud_func_service_account_roles = [
    "roles/monitoring.metricWriter",
    # "roles/compute.admin",
    "roles/compute.instanceAdmin",
]

functions = {
    startInstanceFunc = {
        name = "startInstanceFunc"
        description = "VM instace auto starter function"
        runtime = "nodejs10"
        environment_variables = {}
        // Should be one of: [128, 256, 512, 1024, 2048, 4096, 8192]
        available_memory_mb = 512
        entry_point  = "startInstancePubSub"
        pubsub_topic = "StartInstanceTopic"
    }
    stopInstanceFunc = {
        name = "stopInstanceFunc"
        description = "VM instace auto stopper function"
        runtime = "nodejs10"
        environment_variables = {}
        available_memory_mb = 512
        entry_point = "stopInstancePubSub"
        pubsub_topic = "StopInstanceTopic"
    }
}


cloud_schedulers = {
    "StartInstanceScheduler" = {
        # schedule = "every 10 minutes"
        # everyday at 7:00AM PST"
        pubsub_topic = "StartInstanceTopic"
        schedule   = "30 20 * * *"
        time_zone  = "America/Vancouver"
        data  = {
            "zone" = "northamerica-northeast1-a", 
            "label" = "env=lab"
        }
    }
    "StopInstanceScheduler" = {
        # everyday at 8:20PM PST"
        pubsub_topic = "StopInstanceTopic"
        schedule   = "20 20 * * *"
        time_zone  = "America/Vancouver"
        data  = {
            "zone" = "northamerica-northeast1-a", 
            "label" = "env=lab"
        }
    }
}
