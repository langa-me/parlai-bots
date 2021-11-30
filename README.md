# parlai-bots

Make sure that is repository live in https://github.com/facebookresearch/ParlAI/parlai_internal

```bash
make install
```


## Sync upstream

```bash
git remote add upstream https://github.com/facebookresearch/ParlAI
git fetch upstream
git checkout main
git rebase upstream/main
```

## Getting started

```bash
python3 run.py --config_path=tasks/ava/config.yaml --port 8080
```

In another terminal:
```bash
python3 scripts/client.py
# begin
# begin
# Hi, my name is Louis, I am a space explorer, currently between Mars and Jupyter, do you have an idea where I can grab some food?
# That's great, where I am at the moment is a planet called Mars which isn't good for eating and has no food.
```

## Deploy on Google Cloud Run

```bash
PROJECT_ID="langame-dev"
RUN_NAME="blenderbot"
IMAGE_VERSION="latest"
IMAGE_URL="gcr.io/${PROJECT_ID}/${RUN_NAME}:${IMAGE_VERSION}"
CONFIG_SECRET_ID="blenderbot_config"
RUN_SERVICE_ACCOUNT_ID="blenderbot"
REGION="us-central1"

gcloud secrets create ${CONFIG_SECRET_ID} --data-file ./tasks/ava/blender_400Mdistill.yaml --project=${PROJECT_ID}

# Build Docker image (we use GitHub to install inkdropy dependency)
docker build . -t ${IMAGE_URL} -f ./bot.cpu.Dockerfile

# Check if the container works
docker-compose -f docker-compose.yaml up
# Then 'python3 scripts/client.py'

# If yes, let's deploy to GCP
gcloud auth configure-docker --project=${PROJECT_ID}

# Push image to GCP registry
docker push ${IMAGE_URL}

# Get latest secret version
LATEST_CONFIG_SECRET_VERSION=$(gcloud secrets versions list ${CONFIG_SECRET_ID} --project=${PROJECT_ID} | tail -1 | awk 'NR==1{print $1}')

# Create a service account for the run
gcloud iam service-accounts create ${RUN_SERVICE_ACCOUNT_ID} \
   --project ${PROJECT_ID} \
   --display-name "Blenderbot Cloud Run"

# Grant access to the secrets
gcloud beta secrets add-iam-policy-binding ${CONFIG_SECRET_ID} \
   --project ${PROJECT_ID} \
   --member="serviceAccount:${RUN_SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com" \
   --role=roles/secretmanager.secretAccessor

# Deploy the run worker
gcloud beta run deploy ${RUN_NAME} \
  --project ${PROJECT_ID} \
  --platform managed \
  --region ${REGION} \
  --set-secrets "/etc/secrets/config.yaml=${CONFIG_SECRET_ID}:${LATEST_CONFIG_SECRET_VERSION}" \
  --allow-unauthenticated \
  --max-instances 2 \
  --memory 8192Mi \
  --cpu 2 \
  --timeout 360s \
  --service-account ${RUN_SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com \
  --image ${IMAGE_URL}

SERVICE_URL=$(gcloud beta run services list --project ${PROJECT_ID} --filter="${RUN_NAME}" --format="value(STATUS.address.url)" --limit=1)

gcloud alpha logging tail "resource.type=cloud_run_revision"

```

## TODO

- [ ] deploy a HUGE blenderbot2 on k8s and connect to langame

maybe the bot could listen to firestore and do stuff?
