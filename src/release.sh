#!/bin/bash

set -e

if [ -z "$IMAGE_NAME" ]; then
    echo "Error: Missing IMAGE_NAME environment variable"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Error: Missing VERSION argument. Ex. ./release.sh 1.1.0"
    exit 1
fi

VERSION=$1

activate_gcloud() {
    echo $GCLOUD_API_KEYFILE | base64 -d >~/.gcloud-api-key.json
    gcloud auth activate-service-account --key-file ~/.gcloud-api-key.json
    gcloud config set project $GCLOUD_PROJECT
    gcloud auth configure-docker --quiet
    echo "Activated Google Requirements"
}

push_to_google_container_registry() {
    docker push $IMAGE_NAME
    echo "Pushed to Google Container Registry"
}

set_development_image() {
    kubectl set image deployment $DEPLOYMENT_NAME $DEPLOYMENT_NAME=$IMAGE_NAME:$VERSION --record
    echo "Changed image on `$DEPLOYMENT_NAME` deployment"
}

docker tag $IMAGE_NAME $IMAGE_NAME:$LATEST_TAG
docker tag $IMAGE_NAME $IMAGE_NAME:$VERSION

if [ -z "$GCLOUD_API_KEYFILE" ]; then
    if [ -z "$GCLOUD_PROJECT" ]; then
        echo "Error: Missing GCLOUD_PROJECT environment variable"
        exit 1
    fi
    activate_gcloud
    if [ -z "$PUSH_TO_GCR" ]; then
        push_to_google_container_registry
        if [ -z "$GCLOUD_CLUSTER" ]; then
            if [ -z "$GCLOUD_ZONE" ]; then
                echo "Error: Missing GCLOUD_ZONE environment variable"
                exit 1
            fi
            gcloud container clusters get-credentials $GCLOUD_CLUSTER --zone=$GCLOUD_ZONE --project $GCLOUD_PROJECT
        fi
    fi
fi
if [ -z "$DEPLOYMENT_NAME" ]; then
    set_development_image
fi

