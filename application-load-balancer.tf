resource "aws_alb_target_group" "alb-tg-nexus" {
  name = "alb-tg-nexus"
  port = 8081

  health_check {
    path = "/"
  }

  protocol = "HTTP"
  vpc_id   = var.vpc-id
}

resource "aws_alb" "alb-nexus" {
  name            = "alb-nexus"
  subnets         = var.subnets
  security_groups = [aws_security_group.sg-alb_nexus.id]
}

resource "aws_alb_listener" "alb-ltn_nexus" {
  load_balancer_arn = aws_alb.alb-nexus.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb-tg-nexus.id
    type             = "forward"
  }

  depends_on = [
    aws_alb_target_group.alb-tg-nexus,
    aws_alb.alb-nexus,
  ]
}

