resource "aws_launch_template" "this" {
  name          = "${var.environment}-app"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_security_group_id]
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-app"
      Environment = var.environment
    }
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_tokens = "required"
  }
}   