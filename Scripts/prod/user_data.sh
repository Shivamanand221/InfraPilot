#!/bin/bash

sudo dnf update -y

# Docker
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ec2-user


# CodeDeploy Agent
sudo dnf install ruby wget -y

cd /home/ec2-user

wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install

chmod +x ./install

sudo ./install auto

sudo systemctl enable codedeploy-agent
sudo systemctl start codedeploy-agent


# Strapi configuration
sudo tee /etc/strapi.env > /dev/null <<EOF
ECR_REPOSITORY_URL=${repository_url}
DATABASE_HOST=${db_host}
DATABASE_PORT=${db_port}
DATABASE_NAME=${db_name}
DATABASE_USERNAME=${db_username}
DATABASE_PASSWORD=${db_password}
EOF

sudo chmod 600 /etc/strapi.env