TENANT_NAME=$(ctx tenant name)
DEPLOYMENT_ID=$(ctx deployment id)

ctx logger info "copying ${BINARY}"
cp -fr "${BINARY}" "/opt/manager/resources/deployments/${TENANT_NAME}/${DEPLOYMENT_ID}/chat"
