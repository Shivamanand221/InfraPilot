output "instance_profile_name" {
  description = "The name of the instance profile"
  value       = aws_iam_instance_profile.this.name
}

output "role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.ec2.name
}