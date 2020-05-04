#!/bin/bash
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$INSTANCE_ZONE"
gcloud sql instances delete "$INSTANCE_NAME" --quiet
gsutil rm -r gs://"$BUCKET_NAME"
gcloud iam service-accounts delete "$FULL_SA_NAME" --quiet
kubectl delete secret cloudsql-instance-creds
kubectl delete secret cloudsql-db-credentials
kubectl delete configmap connectionname
