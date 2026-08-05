resource "aws_autoscaling_group" "this" {

  name = "${var.environment}-app-asg"

  max_size = var.max_size
  min_size = var.min_size
  desired_capacity = var.desired_capacity

  launch_template {
    id = var.launch_template_id
    version = var.launch_template_version
  }

  vpc_zone_identifier = var.private_app_subnet_ids

  target_group_arns = [var.target_group_arn]

  health_check_type = "ELB"
  health_check_grace_period = 300

  tag {
    key = "Name"
    value = "${var.environment}-app"
    propagate_at_launch = true
  }

  tag {
    key = "Environment"
    value = var.environment
    propagate_at_launch = true
  }
}