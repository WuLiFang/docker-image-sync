#!/bin/bash

WORKSPACE_DIR="$( dirname "$( realpath "${BASH_SOURCE[0]}" )" )"

if [ -f "$WORKSPACE_DIR/.env" ]; then
  source "$WORKSPACE_DIR/.env"
fi

export DOCKER_REGISTRY
export DOCKER_USERNAME
export DOCKER_PASSWORD
export HTTPS_PROXY


docker run --rm \
  -v "${WORKSPACE_DIR}:/workspace:ro" \
  -e DOCKER_REGISTRY \
  -e DOCKER_USERNAME \
  -e DOCKER_PASSWORD \
  -e HTTPS_PROXY \
  --add-host host.docker.internal:host-gateway \
  --security-opt seccomp=unconfined \
  --entrypoint /bin/bash \
  ${SKOPEO_IMAGE:-quay.io/skopeo/stable:latest} \
  /workspace/sync.sh
