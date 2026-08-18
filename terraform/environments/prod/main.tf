module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr            = var.vpc_cidr
  availability_zone_a = var.availability_zone_a
  availability_zone_b = var.availability_zone_b

  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_b_cidr = var.public_subnet_b_cidr

  private_app_subnet_a_cidr = var.private_app_subnet_a_cidr
  private_app_subnet_b_cidr = var.private_app_subnet_b_cidr

  private_db_subnet_a_cidr = var.private_db_subnet_a_cidr
  private_db_subnet_b_cidr = var.private_db_subnet_b_cidr

  environment = var.environment
}

module "security_group" {
  source      = "../../modules/security-group"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "nat_gateway" {
  source                     = "../../modules/nat-gateway"
  environment                = var.environment
  public_subnet_id           = module.vpc.public_subnet_ids[0]
  private_app_route_table_id = module.vpc.private_app_route_table_id
}

module "rds" {
  source = "../../modules/rds"

  environment = var.environment

  private_db_subnet_ids = module.vpc.private_db_subnet_ids

  rds_security_group_id = module.security_group.rds_security_group_id

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  allocated_storage = var.allocated_storage
  instance_class    = var.instance_class
}

module "iam" {
  source      = "../../modules/iam"
  environment = var.environment
}

module "launch_template" {

  source = "../../modules/launch-template"

  environment = var.environment

  ami_id        = var.ami_id
  instance_type = var.instance_type

  app_security_group_id     = module.security_group.app_security_group_id
  iam_instance_profile_name = module.iam.instance_profile_name

  user_data = templatefile("${path.root}/../../../Scripts/prod/user_data.sh", {
    repository_url = var.repository_url

    db_host     = module.rds.db_address
    db_port     = module.rds.db_port
    db_name     = module.rds.db_name
    db_username = var.db_username
    db_password = var.db_password
    app_keys = jsonencode(var.app_keys)
    admin_jwt_secret    = var.admin_jwt_secret
    api_token_salt      = var.api_token_salt
    transfer_token_salt = var.transfer_token_salt
    encryption_key      = var.encryption_key
  })
}

module "alb" {
  source = "../../modules/alb"

  environment = var.environment

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  alb_security_group_id = module.security_group.alb_security_group_id
}

module "auto_scaling_group" {
  source = "../../modules/auto-scaling"

  environment = var.environment

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = module.launch_template.launch_template_latest_version

  private_app_subnet_ids = module.vpc.private_app_subnet_ids

  target_group_arn = module.alb.target_group_arn

}

module "code_deploy" {
  source = "../../modules/code-deploy"

  environment = var.environment

  autoscaling_group_name = module.auto_scaling_group.auto_scaling_group_name
  target_group_name      = module.alb.target_group_name
}