resource "aws_s3_bucket" "codedeploy" {

    bucket = "${var.environment}-codedeploy-bundles"

    tags = {
        Name = "${var.environment}-codedeploy-bundles"
        Environment = var.environment
    }
}

resource "aws_s3_bucket_versioning" "codedeploy" {
  bucket = aws_s3_bucket.codedeploy.id

  versioning_configuration {
    status = "Enabled"
  }
}