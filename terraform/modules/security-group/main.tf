resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for ${var.environment} alb"
  vpc_id      = var.vpc_id

  # ingress {
  #   description = "SSH"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  /*Removed after adding nginx as a reverse proxy to Strapi. 
    Now only ports 80 and 443 are exposed to the public.
    ONLY IN DEV ENVIRONMENT*/

  # ingress {
  #     description = "Strapi"
  #     from_port = 1337
  #     to_port = 1337
  #     protocol = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}



resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Security group for ${var.environment} app"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.environment}-app-sg"
    Environment = var.environment
  }
}



resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for ${var.environment} rds"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}
