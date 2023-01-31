TENANT_NAME=$(ctx tenant name)
DEPLOYMENT_ID=$(ctx deployment id)

cp -fr "/opt/manager/resources/deployments/${TENANT_NAME}/${DEPLOYMENT_ID}/chat/chat" "${TARGET}"
