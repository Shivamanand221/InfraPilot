resource "aws_db_subnet_group" "this" {

  name       = "${var.environment}-postgres-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.environment}-postgres-subnet-group"
  }
}

resource "aws_db_instance" "this" {

  identifier = "${var.environment}-postgres"
  db_name    = var.db_name
  username   = var.db_username
  password   = var.db_password

  engine         = "postgres"
  engine_version = "16"

  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"

  multi_az = true

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [var.rds_security_group_id]

  storage_encrypted       = true
  skip_final_snapshot     = true
  publicly_accessible     = false
  backup_retention_period = 7

  deletion_protection = false
  apply_immediately   = true

  tags = {
    Name        = "${var.environment}-postgres-db"
    Environment = var.environment
  }
}