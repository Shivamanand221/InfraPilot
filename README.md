# Strapi Production Deployment

Production DevOps project for deploying a containerized Strapi application on AWS using Terraform, Docker, GitHub Actions, Amazon ECR, Amazon S3, and AWS CodeDeploy Blue/Green deployments.

## Overview

The deployment flow is:

```text
GitHub
   ↓
GitHub Actions
   ├── Docker build
   ├── ECR push
   ├── deployment bundle
   └── S3 upload
          ↓
      CodeDeploy
          ↓
    Blue/Green deployment
          ↓
  Replacement EC2 fleet
          ↓
 ApplicationStart
          ↓
 ValidateService
          ↓
    ALB traffic shift
          ↓
 Original fleet termination
```

The project has been validated with multiple consecutive successful deployments.

## Technology Stack

| Component | Technology |
|---|---|
| Infrastructure as Code | Terraform |
| Cloud | AWS |
| Application | Strapi |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Container Registry | Amazon ECR |
| Deployment Artifacts | Amazon S3 |
| Deployment | AWS CodeDeploy |
| Strategy | Blue/Green |
| Compute | EC2 + Auto Scaling |
| Load Balancing | Application Load Balancer |
| Database | RDS PostgreSQL |
| AWS Authentication | GitHub Actions OIDC + IAM |
| Networking | Amazon VPC |

## Architecture

```text
                         GitHub
                            |
                            v
                    GitHub Actions
                            |
             +--------------+--------------+
             |              |              |
             v              v              v
          Docker          ECR             S3
           Build          Push       Deployment ZIP
             |              |              |
             +--------------+--------------+
                            |
                            v
                       CodeDeploy
                            |
                     Blue/Green Fleet
                            |
             +--------------+--------------+
             |                             |
             v                             v
       Replacement Fleet             Original Fleet
          EC2 x 2                       EC2 x 2
             |                             |
             +-------------+---------------+
                           |
                           v
                    Application Load
                       Balancer
                           |
                           v
                       Strapi
                           |
                           v
                    RDS PostgreSQL
```

## Infrastructure

Terraform provisions the production environment, including:

- VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Route tables
- Application Load Balancer
- Target Group
- EC2 Launch Template
- Auto Scaling Group
- Security Groups
- RDS PostgreSQL
- IAM roles and instance profile
- CodeDeploy application and deployment group
- Deployment S3 bucket
- ECR repository

Application EC2 instances run in private application subnets, while the load balancer provides the application entry point.

## Project Structure

```text
InfraPilot/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
│
├── docker/
│   ├── nginx/
│   │   └── default.conf
│   └── docker-compose.yml
│
├── Scripts/
│   ├── dev/
│   │   ├── update-github-secrets.sh
│   │   └── user_data.sh
│   │
│   └── prod/
│       ├── appspec.yml
│       ├── start.sh
│       ├── stop.sh
│       ├── user_data.sh
│       └── validate.sh
│
├── Strapi/
│   └── ...
│
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   │
│   └── modules/
│       ├── alb/
│       ├── auto-scaling/
│       ├── code-deploy/
│       ├── ec2/
│       ├── iam/
│       ├── launch-template/
│       ├── nat-gateway/
│       ├── rds/
│       ├── security-group/
│       └── vpc/
│
├── .gitignore
├── README.md
├── service.conf.lock
├── system.conf.lock
└── terraform.tfstate
```


## Terraform

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Destroy:

```bash
terraform destroy
```

### Terraform State

The production Terraform state is stored remotely in S3 with DynamoDB-based locking.

If Terraform reports:

```text
Error acquiring the state lock
ConditionalCheckFailedException
```

first verify that another Terraform process is not running. Avoid disabling locking unless the implications are understood.

## CI/CD Pipeline

The production workflow runs when code is pushed to `main`.

Main stages:

1. Checkout source
2. Configure AWS credentials using OIDC
3. Login to ECR
4. Generate image tag
5. Build Docker image
6. Push image to ECR
7. Create `image.env`
8. Create CodeDeploy bundle
9. Upload bundle to S3
10. Create CodeDeploy deployment

The image tag is based on the GitHub commit SHA and run attempt:

```bash
echo "IMAGE_TAG=${GITHUB_SHA}-${GITHUB_RUN_ATTEMPT}" >> "$GITHUB_ENV"
```

Docker image:

```bash
docker build   -t "${ECR_REPOSITORY_URL}:${IMAGE_TAG}"   ./Strapi
```

Push:

```bash
docker push   "${ECR_REPOSITORY_URL}:${IMAGE_TAG}"
```

## Deployment Bundle

The CodeDeploy ZIP contains:

```text
deployment.zip
├── appspec.yml
├── start.sh
├── stop.sh
├── validate.sh
└── image.env
```

`image.env` records the exact image used by the deployment:

```text
ECR_REPOSITORY_URL=...
IMAGE_TAG=...
```

The pipeline creates it with:

```bash
echo "ECR_REPOSITORY_URL=${ECR_REPOSITORY_URL}" > image.env
echo "IMAGE_TAG=${IMAGE_TAG}" >> image.env
```

## CodeDeploy Lifecycle

```text
ApplicationStop
      ↓
DownloadBundle
      ↓
BeforeInstall
      ↓
Install
      ↓
AfterInstall
      ↓
ApplicationStart
      ↓
ValidateService
      ↓
Traffic Shift
      ↓
Original Fleet Termination
```

Example `appspec.yml`:

```yaml
version: 0.0

os: linux

hooks:
  ApplicationStop:
    - location: stop.sh
      timeout: 300
      runas: root

  ApplicationStart:
    - location: start.sh
      timeout: 300
      runas: root

  ValidateService:
    - location: validate.sh
      timeout: 300
      runas: root
```

## Blue/Green Deployment

The deployment group uses CodeDeploy Blue/Green deployment.

```text
Current / Blue
      |
      | Existing traffic
      v
   EC2 fleet
      |
   CodeDeploy
      |
      v
Replacement / Green
      |
      v
Health checks
      |
      v
Traffic shift
      |
      v
Blue fleet terminated
```

Replacement instances are provisioned and validated before traffic is shifted.

## Environment and Secrets

Application configuration is loaded on the EC2 host:

```bash
source /etc/strapi.env
```

Deployment-specific image information is loaded from:

```bash
source ./image.env
```

Sensitive values should never be committed to Git.

Examples:

- Database password
- Strapi application keys
- Admin JWT secret
- API token salt
- Transfer token salt
- Encryption key

## Verification

Check deployment:

```bash
aws deploy get-deployment   --deployment-id <DEPLOYMENT_ID>   --query 'deploymentInfo.[status,createTime,completeTime,deploymentGroupName]'   --output table
```

List deployment instances:

```bash
aws deploy list-deployment-instances   --deployment-id <DEPLOYMENT_ID>
```

Inspect lifecycle events:

```bash
aws deploy get-deployment-instance   --deployment-id <DEPLOYMENT_ID>   --instance-id <INSTANCE_ID>   --query 'instanceSummary.lifecycleEvents[*].[lifecycleEventName,status,errorCode,message]'   --output table
```

Check ASGs:

```bash
aws autoscaling describe-auto-scaling-groups   --query 'AutoScalingGroups[].[AutoScalingGroupName,DesiredCapacity,MinSize,MaxSize]'   --output table
```

Check ALB:

```bash
aws elbv2 describe-load-balancers   --names prod-alb   --query 'LoadBalancers[0].[LoadBalancerName,State.Code,DNSName]'   --output table
```

Check RDS:

```bash
aws rds describe-db-instances   --db-instance-identifier prod-postgres   --query 'DBInstances[0].[DBInstanceStatus,Endpoint.Address]'   --output table
```

## Troubleshooting

### Terraform state lock

```text
Error acquiring the state lock
ConditionalCheckFailedException
```

Check for another active Terraform process before taking any lock-recovery action.

### S3 bucket cannot be deleted

```text
BucketNotEmpty
You must delete all versions in the bucket.
```

For a versioned deployment bucket, inspect object versions:

```bash
aws s3api list-object-versions   --bucket <BUCKET_NAME>   --output json
```

All versions and delete markers must be removed before deleting the bucket.

### CodeDeploy ApplicationStart failure

A previous deployment failed with:

```text
docker: Error response from daemon:
Conflict. The container name "/strapi" is already in use
```

This occurs when a container named `strapi` already exists on the deployment host. The deployment scripts must safely handle the existing container before starting another container with the same name.

### `image.env` missing

A previous deployment reported:

```text
./image.env: No such file or directory
```

The pipeline was corrected to explicitly include `image.env` in the deployment bundle:

```bash
cp image.env deploy-bundle/
```

### EC2 ENIs blocking subnet deletion

If Terraform waits while deleting a subnet, inspect network interfaces:

```bash
aws ec2 describe-network-interfaces   --filters "Name=vpc-id,Values=<VPC_ID>"   --query 'NetworkInterfaces[].[NetworkInterfaceId,Status,InterfaceType,SubnetId,Groups[0].GroupId,Description]'   --output table
```

For an `in-use` ENI, inspect its attachment:

```bash
aws ec2 describe-network-interfaces   --network-interface-ids <ENI_ID>   --query 'NetworkInterfaces[].[NetworkInterfaceId,InterfaceType,RequesterId,RequesterManaged,Attachment.InstanceId,Description]'   --output table
```

If it is a primary ENI belonging to an obsolete EC2 instance, terminate the parent instance rather than directly deleting the in-use primary ENI.

### RDS takes several minutes

RDS operations are asynchronous. Check:

```bash
aws rds describe-db-instances   --db-instance-identifier prod-postgres   --query 'DBInstances[0].[DBInstanceStatus,DBInstanceIdentifier]'   --output table
```

Statuses such as:

```text
creating
backing-up
deleting
available
```

can appear during the lifecycle.

## Deployment Checklist

### Before deployment

```text
[ ] Terraform infrastructure is applied
[ ] RDS is available
[ ] ALB is active
[ ] EC2/ASG is healthy
[ ] ECR repository exists
[ ] CodeDeploy application exists
[ ] CodeDeploy deployment group exists
[ ] GitHub OIDC role is configured
[ ] Required GitHub secrets exist
```

### During deployment

```text
[ ] Docker image builds
[ ] Image is pushed to ECR
[ ] image.env is created
[ ] deployment.zip contains required files
[ ] Bundle is uploaded to S3
[ ] CodeDeploy deployment starts
[ ] Replacement instances are provisioned
[ ] ApplicationStart succeeds
[ ] ValidateService succeeds
[ ] Traffic shifts successfully
```

### After deployment

```text
[ ] Replacement instances are healthy
[ ] ALB targets are healthy
[ ] Application responds through ALB
[ ] Original fleet is terminated
[ ] No unexpected deployment fleet remains
```

## Project Status

**Working and validated.**

The infrastructure has been successfully recreated with Terraform and the production deployment has been successfully executed multiple times using GitHub Actions and AWS CodeDeploy Blue/Green deployment.

```text
Terraform
   ↓
AWS Infrastructure
   ↓
GitHub Actions
   ↓
Docker
   ↓
ECR
   ↓
S3
   ↓
CodeDeploy
   ↓
Blue/Green
   ↓
ALB
   ↓
Strapi + RDS PostgreSQL
```

## Author

Hands-on DevOps project covering Infrastructure as Code, AWS networking, Docker, CI/CD, GitHub Actions, IAM/OIDC, ECR, EC2, Auto Scaling, ALB, RDS, S3, CodeDeploy, Blue/Green deployments, and production troubleshooting.
