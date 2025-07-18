resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [var.sg_id]
  tags               = {
    Name = var.name_prefix
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.name_prefix}-tg"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "lis" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tga" {
  for_each = var.instance_map

  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = each.value
  port             = var.port
}

