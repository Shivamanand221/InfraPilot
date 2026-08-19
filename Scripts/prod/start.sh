#!/bin/bash

source /etc/strapi.env
source ./image.env

aws_region="us-east-1"

aws_account_id=$(aws sts get-caller-identity \
    --query "Account" \
    --output text)

aws ecr get-login-password --region "${aws_region}" \
    | docker login \
    --username AWS \
    --password-stdin "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com"

docker pull "${ECR_REPOSITORY_URL}:${IMAGE_TAG}"

docker run -d \
    --name strapi \
    --restart unless-stopped \
    -p 80:1337 \
    -e DATABASE_CLIENT=postgres \
    -e DATABASE_HOST="${DATABASE_HOST}" \
    -e DATABASE_PORT="${DATABASE_PORT}" \
    -e DATABASE_NAME="${DATABASE_NAME}" \
    -e DATABASE_USERNAME="${DATABASE_USERNAME}" \
    -e DATABASE_PASSWORD="${DATABASE_PASSWORD}" \
    -e DATABASE_SSL=true \
    -e DATABASE_SSL_REJECT_UNAUTHORIZED=false \
    -e APP_KEYS="${APP_KEYS}" \
    -e ADMIN_JWT_SECRET="${ADMIN_JWT_SECRET}" \
    -e API_TOKEN_SALT="${API_TOKEN_SALT}" \
    -e TRANSFER_TOKEN_SALT="${TRANSFER_TOKEN_SALT}" \
    -e ENCRYPTION_KEY="${ENCRYPTION_KEY}" \
    "${ECR_REPOSITORY_URL}:${IMAGE_TAG}"