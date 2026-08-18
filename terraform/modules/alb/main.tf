resource "aws_lb" "this" {

  name = "${var.environment}-alb"

  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.alb_security_group_id]

  subnets = var.public_subnet_ids

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "this" {

  name = "${var.environment}-tg"

  vpc_id = var.vpc_id

  target_type = "instance"

  port     = 80
  protocol = "HTTP"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.environment}-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}