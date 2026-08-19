resource "aws_iam_role" "this" {
  name = "${var.environment}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "codedeploy.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.environment}-codedeploy-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role =aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "this" {
  name = "${var.environment}-codedeploy-app"
  compute_platform = "Server"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "launch_template_permissions" {
  name = "${var.environment}-codedeploy-launch-template"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:RunInstances",
          "ec2:CreateTags"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.environment}-ec2-role"
      }
    ]
  })
}

resource "aws_codedeploy_deployment_group" "this" {
    app_name = aws_codedeploy_app.this.name
    deployment_group_name = "${var.environment}-deployment-group"

    service_role_arn = aws_iam_role.this.arn

    deployment_style {
      deployment_type = "BLUE_GREEN"
      deployment_option = "WITH_TRAFFIC_CONTROL"
    }

    blue_green_deployment_config {
      
        green_fleet_provisioning_option {
          action = "COPY_AUTO_SCALING_GROUP"
        }

        deployment_ready_option {
          action_on_timeout = "CONTINUE_DEPLOYMENT"
        }

        terminate_blue_instances_on_deployment_success {
          action = "TERMINATE"
          termination_wait_time_in_minutes = 5
        }

    }

    auto_rollback_configuration {
      enabled = true

      events = ["DEPLOYMENT_FAILURE"]
    }

    load_balancer_info {
      
      target_group_info {
        name = var.target_group_name
      }
    }

    autoscaling_groups = [
        var.autoscaling_group_name
    ]
}
