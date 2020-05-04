#!/bin/bash
helm delete $(helm ls --short)
kubectl delete secret cloudsql-instance-creds
kubectl delete secret cloudsql-db-credentials
kubectl delete configmap connectionname
kubectl delete --all pods
