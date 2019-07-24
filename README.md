# Google Kubernetes Engine (/w Semantic Release)

[![docker automated build](https://img.shields.io/docker/cloud/automated/bjerk/gke-semantic-release.svg)](https://hub.docker.com/r/bjerk/gke-semantic-release)

A builder image Google Cloud (Kubernetes Engine) using [Semantic Release](https://github.com/semantic-release/semantic-release). Comes with an opinionated [builder utility](/src/release.sh) that can fully build a Docker image, tag it, upload to Google Container Registry and deploy it to Kubernetes Engine (or any Kubernetes). Production-ready (as production ready a builder image could be).

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

## Customize `semantic-release`
When using the opinionated builder utility, you are (at this time) limited to using the [dependencies](src/package.json). However, you can always use `semantic-release` with your
dependencies and configuration. 

In any folder in your repository, add a `package.json` containing e.g. `@semantic-release/changelog` as a dependency and a `semantic-release` [configuration](https://semantic-release.gitbook.io/semantic-release/usage/configuration). Install these dependencies with your build pipeline and run `semantic-release` command. The `semantic-release` is added to `PATH` (meaning it's globally installed in the Docker image).

# Motivation
Installing dependencies is wasteful time, and since we (Bjerk) have so many projects that requires the ones included in this Dockerfile – we figured it's time to Open Source it. Probably a few more than just us.


# Environment Variables
These environment variables relates to `semantic-release` configuration and the included builder utility. By default the `CMD` is set to have `--extends /builder/releaserc.json`, this uses `semantic-release`'s plugins; `commit-analyzer`, `release-notes-generator`, `git`, `exec`.
The `exec` step runs a Shell-script in `/builder/release.sh`. This script activates the `gcloud` command utility with a service account provided by the `GCLOUD_API_KEYFILE`. If provided, it also pushes the built Dockerfile (built by your CI/CD pipeline) in a separate step before it deploys the image to your Kubernetes cluster (read more about this under `DEPLOYMENT_NAME`).

### `IMAGE_NAME` (required)
Name of the image. E.g. `us.gcr.io/my-project/image`. The version will be appended incl. `latest`.

### `DOCKER_PUSH` (default = true)
When the `DOCKER_PUSH` environment variable is set to `true` (case-sensitive) the builder utility
will run `docker push` on the `IMAGE_NAME` image. This is set by default to `true`.

### `GCLOUD_API_KEYFILE`
The `GCLOUD_API_KEYFILE` must be a base64 encoded Google Service Account key that
has access to Google Container Registry and Kubernetes Engine. If not applied,
no Google-releated functionality will be activated.

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

### `DEPLOYMENT_NAMESPACE`
If applied, namespace attribute are added to `set image deployment` operation.

### `RELEASE_BRANCH` (default = `master`)
When using default `ENTRYPOINT` command (`semantic-release`). We run the command with `--branch` arguments and `RELEASE_BRANCH` are used to fill this argument.

### `LATEST_TAG` (default = `latest`)
The builder utility tags your Docker images (provided that they are built using the same name
as `IMAGE_NAME`) will be tagged with a Semver version (provided by `semantic-release`). You
can change this from `latest` to what you'd like with setting this environment variable.

# Contribute

We are very much open to changes on this image. Opinions are welcome as issues (please tag them, that helps). Please open PRs or get in touch!

## License

**[MIT](LICENSE)** Licensed