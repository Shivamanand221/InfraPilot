resource "aws_ecr_repository" "this" {

  name = "${var.environment}-ecr-repository"

  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name        = "${var.environment}-ecr-repository"
    Environment = var.environment
  }
}