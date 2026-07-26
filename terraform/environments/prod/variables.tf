variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zone_a" {
  type = string
}

variable "availability_zone_b" {
  type = string
}

variable "public_subnet_a_cidr" {
  type = string
}

variable "public_subnet_b_cidr" {
  type = string
}

variable "private_app_subnet_a_cidr" {
  type = string
}

variable "private_app_subnet_b_cidr" {
  type = string
}

variable "private_db_subnet_a_cidr" {
  type = string
}

variable "private_db_subnet_b_cidr" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ami_id" {
  type = string
}