FROM google/cloud-sdk:alpine

ADD ./src /builder

# nvm environment variables
ENV RELEASE_BRANCH master
ENV LATEST_TAG latest

RUN apk add curl bash nodejs nodejs-npm yarn

# Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Add semantic release
RUN cd /builder/ && npm install && chmod +x /builder/release.sh
ENV PATH /builder/node_modules/.bin/:$PATH

RUN gcloud --version && \
    kubectl version --client && \
    node -v && \
    npm -v && \
    semantic-release -v

CMD ["--branch ${RELEASE_BRANCH}", "--extends /build/releaserc.json"]

ENTRYPOINT [ "semantic-release" ]