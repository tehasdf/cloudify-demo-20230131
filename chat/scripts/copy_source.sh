
TENANT_NAME=$(ctx tenant name)
BLUEPRINT_ID=$(ctx blueprint id)
DEPLOYMENT_ID=$(ctx deployment id)

cp -fr "/opt/manager/resources/blueprints/${TENANT_NAME}/${BLUEPRINT_ID}/chat" "/opt/manager/resources/deployments/${TENANT_NAME}/${DEPLOYMENT_ID}/chat"
