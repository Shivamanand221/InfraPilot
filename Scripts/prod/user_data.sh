sudo dnf update -y

sudo dnf install docker -y  
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ec2-user

aws ecr get-login-password

docker pull <your-ecr-repository-uri>:<tag>
