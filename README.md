<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Functions - Scheduling GCE Instances sample

## Deploy and run the sample

See the [Scheduling Instances with Cloud Scheduler tutorial][tutorial].

[tutorial]: https://cloud.google.com/scheduler/docs/scheduling-instances-with-cloud-scheduler

## Run the tests

1. Install dependencies:

        npm install

1. Run the tests:

        npm test

## Additional resources

* [GCE NodeJS Client Library documentation][compute_nodejs_docs]
* [Background Cloud Functions documentation][background_functions_docs]

[compute_nodejs_docs]: https://cloud.google.com/compute/docs/tutorials/nodejs-guide
[background_functions_docs]: https://cloud.google.com/functions/docs/writing/background


## Detail procedure (copied from the tutorial link above)

### Setup Compute Engine instances to use labels
```
gcloud compute instances create dev-instance \
    --network default \
    --zone us-west1-b \
    --labels=env=dev
```

### Create pubsub topic
```
gcloud pubsub topics create start-instance-event
gcloud pubsub topics create stop-instance-event
```

### Deploy
```
gcloud functions deploy startInstanceFunc \
    --trigger-topic start-instance-event \
    --runtime nodejs10 \
    --allow-unauthenticated
gcloud functions deploy stopInstanceFunc \
    --trigger-topic stop-instance-event \
    --runtime nodejs10 \
    --allow-unauthenticated
```

### Test
```
DATA=$(echo '{"zone":"northamerica-northeast1-a", "label":"env=lab"}' | base64)
echo $DATA
gcloud functions call stopInstanceFunc \
    --data '{"zone":"northamerica-northeast1-a", "label":"env=lab"}'

DATA='{"zone":"northamerica-northeast1-a", "label":"env=lab"}'
TOPIC_ID=StopInstanceTopic
gcloud pubsub topics publish $TOPIC_ID \
  --project $PROJECT \
  --message=$DATA 

TOPIC_ID=StartInstanceTopic
gcloud pubsub topics publish $TOPIC_ID \
  --project $PROJECT \
  --message=$DATA 

ZONE=northamerica-northeast1-a

gcloud compute instances list --filter="labels.env=lab" --zones $ZONE --project $PROJECT