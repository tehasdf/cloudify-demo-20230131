sudo systemctl disable chat.service
sudo rm /etc/systemd/system/chat.service
sudo rm /opt/chat
sudo systemctl daemon-reload