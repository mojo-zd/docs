FROM golang:1.11-alpine

ENV HELM_VERSION="v2.14.2"

RUN apk update && apk add bash && \
    apk add openssl && \
    apk add make && \
    apk add curl && \
    curl -L https://git.io/get_helm.sh | bash && \
    curl -sSL https://git.io/get-mo -o mo && \
    chmod +x mo && \
    mv mo /usr/local/bin/ && \
    wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm
