resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  associate_public_ip_address = true

  iam_instance_profile = var.instance_profile_name

  tags = {
    Name        = "${var.environment}-ec2"
    Environment = var.environment
  }
  user_data = var.user_data
}