output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_ids[0]
}

output "alb_security_group_id" {
  value = module.security_group.alb_security_group_id
}

output "app_security_group_id" {
  value = module.security_group.app_security_group_id
}

output "rds_security_group_id" {
  value = module.security_group.rds_security_group_id
}

/*output "instance_id" {
  value = module.ec2.instance_id
}

output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}

output "public_dns" {
  value = module.ec2.instance_public_dns
}*/

output "db_address" {
  value = module.rds.db_address
}

output "db_port" {
  value = module.rds.db_port
}

output "codedeploy_bucket_name" {
  value = aws_s3_bucket.codedeploy.bucket
}