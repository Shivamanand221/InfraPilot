module "vpc" {
  source                    = "../../modules/vpc"
  vpc_cidr                  = var.vpc_cidr
  availability_zone_a       = var.availability_zone_a
  availability_zone_b       = var.availability_zone_b
  public_subnet_a_cidr      = var.public_subnet_a_cidr
  public_subnet_b_cidr      = var.public_subnet_b_cidr
  private_app_subnet_a_cidr = var.private_app_subnet_a_cidr
  private_app_subnet_b_cidr = var.private_app_subnet_b_cidr
  private_db_subnet_a_cidr  = var.private_db_subnet_a_cidr
  private_db_subnet_b_cidr  = var.private_db_subnet_b_cidr
  environment               = var.environment
}

module "security_group" {
  source      = "../../modules/security-group"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "ec2" {
  source            = "../../modules/ec2"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_group.app_security_group_id
  key_name          = var.key_name
  environment       = var.environment
  user_data         = file("${path.root}/../../../Scripts/user_data.sh")
}

module "nat_gateway" {
  source                     = "../../modules/nat-gateway"
  environment                = var.environment
  public_subnet_id           = module.vpc.public_subnet_ids[0]
  private_app_route_table_id = module.vpc.private_app_route_table_id
}