#!/bin/bash

#gcloud config set project "$PROJECT"
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$INSTANCE_ZONE"

function enable_api() {
  SERVICE=$1
  if [[ $(gcloud services list --format="value(serviceConfig.name)" \
                                --filter="serviceConfig.name:$SERVICE" 2>&1) != \
                                "$SERVICE" ]]; then
    echo "Enabling $SERVICE"
    gcloud services enable "$SERVICE"
  else
    echo "$SERVICE is already enabled"
  fi
}

enable_api sqladmin.googleapis.com
enable_api container.googleapis.com
enable_api iam.googleapis.com

gcloud sql instances create --zone "$INSTANCE_ZONE" --database-version POSTGRES_9_6 --memory 4 --cpu 2 "$INSTANCE_NAME" 
gcloud sql databases create "$DB_NAME" --instance="$INSTANCE_NAME" 
gcloud sql users set-password postgres --instance "$INSTANCE_NAME"  --password "$DB_PASS"
#gcloud sql users create "$USER_NAME" --host '%' --instance "$INSTANCE_NAME" --password "$USER_PASSWORD"
gsutil mb -b on -l "$BUCKET_REGION" gs://"$BUCKET_NAME"/

if [ -z "$PROJECT" ]; then
  echo "No default project set. Please set one with gcloud config"
  exit 1
fi

gcloud iam service-accounts create "$SA_NAME" --display-name "$SA_NAME"
gcloud projects add-iam-policy-binding "$PROJECT" \
--member serviceAccount:"$FULL_SA_NAME" \
--role roles/cloudsql.client > /dev/null

gcloud iam service-accounts keys create credentials.json --iam-account "$FULL_SA_NAME"
kubectl --namespace default create secret generic cloudsql-instance-creds --from-file=credentials.json=credentials.json

kubectl --namespace default create secret generic cloudsql-db-credentials \
--from-literal=username="$DB_USER" \
--from-literal=password="$DB_PASS" \
--from-literal=dbname="$DB_NAME"

CONNECTION_NAME=$(gcloud sql instances describe "$INSTANCE_NAME" \
--format="value(connectionName)")

kubectl --namespace default create configmap connectionname --from-literal=connectionname="$CONNECTION_NAME"
