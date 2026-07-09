#!/usr/bin/env bash

set -e

exec > >(tee /var/log/user-data.log) 2>&1

echo "========== EC2 User Data Started =========="

# -------------------------------------------------
# Update packages
# -------------------------------------------------
sudo yum update -y

# -------------------------------------------------
# Install Git & Docker
# -------------------------------------------------
sudo yum install -y git docker

# -------------------------------------------------
# Enable & Start Docker
# -------------------------------------------------
sudo systemctl enable docker
sudo systemctl start docker

# -------------------------------------------------
# Add ec2-user to docker group
# -------------------------------------------------
sudo usermod -aG docker ec2-user

# -------------------------------------------------
# Install Docker Compose Plugin
# -------------------------------------------------
DOCKER_CONFIG=/usr/local/lib/docker

sudo mkdir -p "$DOCKER_CONFIG/cli-plugins"

sudo curl -SL \
https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
-o "$DOCKER_CONFIG/cli-plugins/docker-compose"

sudo chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"

# -------------------------------------------------
# Clone Repository
# -------------------------------------------------
cd /home/ec2-user

if [ ! -d "Strapi_Project" ]; then
    git clone https://github.com/shivamanand221/Strapi_Project.git
fi

# -------------------------------------------------
# Start Application
# -------------------------------------------------
cd /home/ec2-user/Strapi_Project/docker

docker compose pull
docker compose up -d

echo "========== EC2 User Data Completed =========="