#!/usr/bin/env bash
set -x
export PATH=/home/centos/.nimble/bin:$PATH
TENANT_NAME=$(ctx tenant name)
DEPLOYMENT_ID=$(ctx deployment id)

pushd "/tmp/resources/deployments/${TENANT_NAME}/${DEPLOYMENT_ID}/chat"
    nimble build "${FLAGS}"
popd
