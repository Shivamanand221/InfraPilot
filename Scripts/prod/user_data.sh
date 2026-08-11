sudo dnf update -y

sudo dnf install docker -y  
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ec2-user

aws_region="us-east-1"
aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)

aws ecr get-login-password --region "$${aws_region}" \
    | docker login \
    --username AWS \
    --password-stdin "$${aws_account_id}.dkr.ecr.$${aws_region}.amazonaws.com"

docker pull ${repository_url}:latest

docker rm -f strapi || true

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
    ${repository_url}:latest