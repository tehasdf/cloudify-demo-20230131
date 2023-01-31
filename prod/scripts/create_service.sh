TENANT_NAME=$(ctx tenant name)
DEPLOYMENT_ID=$(ctx deployment id)

sudo cp "/tmp/resources/deployments/${TENANT_NAME}/${DEPLOYMENT_ID}/chat" "/opt/chat"

sudo tee /etc/systemd/system/chat.service  <<EOF
[Unit]
After=network.target

[Service]
ExecStart=/opt/chat
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable chat.service
