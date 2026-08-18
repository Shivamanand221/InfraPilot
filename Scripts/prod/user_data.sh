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

# Login to ECR
aws_region="us-east-1"

aws_account_id=$(aws sts get-caller-identity \
  --query "Account" \
  --output text)

aws ecr get-login-password \
  --region "$aws_region" \
  | docker login \
  --username AWS \
  --password-stdin \
  "$aws_account_id.dkr.ecr.$aws_region.amazonaws.com"


# Pull initial Strapi image
docker pull ${repository_url}:v1


# Remove existing container if present
docker rm -f strapi || true


# Start Strapi
docker run -d \
  --name strapi \
  --restart unless-stopped \
  -p 80:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST=${db_host} \
  -e DATABASE_PORT=${db_port} \
  -e DATABASE_NAME=${db_name} \
  -e DATABASE_USERNAME=${db_username} \
  -e DATABASE_PASSWORD=${db_password} \
  -e DATABASE_SSL=true \
  -e DATABASE_SSL_REJECT_UNAUTHORIZED=false \
  -e APP_KEYS='${app_keys}' \
  -e ADMIN_JWT_SECRET='${admin_jwt_secret}' \
  -e API_TOKEN_SALT='${api_token_salt}' \
  -e TRANSFER_TOKEN_SALT='${transfer_token_salt}' \
  -e ENCRYPTION_KEY='${encryption_key}' \
  ${repository_url}:v1