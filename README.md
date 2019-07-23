# Google Kubernetes Engine (/w Semantic Release)

[![docker automated build](https://img.shields.io/docker/automated/bjerk/gke-semantic-release.svg)](https://hub.docker.com/bjerk/gke-semantic-release)

A builder image Google Cloud (Kubernetes Engine) using Semantic Release. Comes with a builder utiltiy that can fully build a Docker image, tag it, upload to Google Container Registry and deploy it to Kubernetes Engine (or any other Kubernetes). Production-ready (as production ready a builder image could be).

# Quick reference

-	**Where to get help**:  
	[the Docker Community Forums](https://forums.docker.com/), [the Docker Community Slack](https://blog.docker.com/2016/11/introducing-docker-community-directory-docker-community-slack/), or [Stack Overflow](https://stackoverflow.com/search?tab=newest&q=docker)

-	**Where to file issues**:  
	[https://github.com/Bjerkio/gke-semantic-release/issues](https://github.com/Bjerkio/gke-semantic-release/issues)

-	**Maintained by**:  
	[Bjerk AS](https://github.com/Bjerkio)

-	**Source of this description**:  
	[README.md in main repo](https://github.com/Bjerkio/gke-semantic-release)

## What is included?

 - Node (latest version in `apk`)
 - Semantic Release
 - kubectl
 - gcloud
 - gsutil

# Motivation

Installing dependencies is wasteful time, and since we (Bjerk) have so many projects that requires the ones included in this Dockerfile – we figured it's time to Open Source it. Probably a few more than just us.

# Environment Variables
These environment variables relates to `semantic-release` configuration that comes with this image. By default the `CMD` is set to have `--extends /builder/releaserc.json`. This uses `semantic-release`'s plugins; `commit-analyzer`, `release-notes-generator`, `git`, `exec`.
The `exec` step runs a Shell-script in `/builder/release.sh`. This script activates the `gcloud` command utility with a service account provided by the `GCLOUD_API_KEYFILE`. If provided, it also pushes the built Dockerfile (built by your CI/CD pipeline) in a separate step before it deploys the image to your Kubernetes cluster (read more about this under `DEPLOYMENT_NAME`).

## I just want the dependencies in an image.
Just use the image as you'd like. You don't have to run semantic-release, use the default builder scripts or configuration files. In most CI/CD solutions, you have to write your own command lines anyway – so go at it!

### `IMAGE_NAME` (required)
Name of the image. E.g. `us.gcr.io/my-project/image`. The version will be appended incl. `latest`.

### `GCLOUD_API_KEYFILE`
When this is applied (along with the environment variables below), the builder will push the Docker file to Google Container Registry.

### `GCLOUD_PROJECT`
Your Google Cloud Platform project id. Required when GCLOUD_API_KEYFILE is applied.

### `GCLOUD_CLUSTER`
When this is applied, the builder will get Kubernetes Engine credentials at build time.
Combined with `DEPLOYMENT_NAME`, you can fully deploy to GKE with this utility.

### `GCLOUD_ZONE`
The zone where your cluster is located. *This is required when deploying to Kubernetes Engine* 

### `DEPLOYMENT_NAME`
This is the name of the Kubernetes deployment. When this variable is set, the builder will
run this command.
`kubectl set image deployment $DEPLOYMENT_NAME $DEPLOYMENT_NAME=$IMAGE_NAME:$VERSION --record`

### `RELEASE_BRANCH` (default = `master`)
When using default `ENTRYPOINT` command (`semantic-release`). We run the command with `--branch` arguments and `RELEASE_BRANCH` are used to fill this argument.

### `LATEST_TAG` (default = `latest`)
The builder utility tags your Docker images (provided that they are built using the same name
as `IMAGE_NAME`) will be tagged with a Semver version (provided by `semantic-release`). You
can change this from `latest` to what you'd like with setting this environment variable.

# Contribute

We are very much open to changes this this image. Opinions are welcome as issues (please tag them, that helps). Please open PRs or get in touch!

## License

**[MIT](LICENSE)** Licensed