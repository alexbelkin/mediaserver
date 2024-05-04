#!/bin/bash

# Configuration variables
PROJECT_NAME="mediaserver"
PROJECT_PATH="/projects/${PROJECT_NAME}"
CONFIG_DIR="${PROJECT_PATH}/config"
MEDIA_DIR="${PROJECT_PATH}media"

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Create configuration and media directories if they do not exist
mkdir -p "${CONFIG_DIR}" "${MEDIA_DIR}"


# Create systemd service file for ${PROJECT_NAME}
cat <<EOF > /etc/systemd/system/mediaserver.service
[Unit]
Description=Media Server Docker Compose Service
Requires=docker.service
After=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/projects/mediaserver
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
Restart=always
RestartSec=10s  # Wait a few seconds before restarting to avoid rapid failure loops

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
systemctl daemon-reload

# Enable the service to start on boot
systemctl enable "$SERVICE_NAME"

# Start the service
systemctl start "$SERVICE_NAME"

echo "Jellyfin Media Server is installed and running."
