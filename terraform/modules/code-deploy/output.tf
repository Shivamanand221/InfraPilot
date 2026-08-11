output "codedeploy_app_name" {
  value = aws_codedeploy_app.this.name
}

output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.this.deployment_group_name
}

output "codedeploy_role_arn" {
  value = aws_codedeploy_app.this.arn
}