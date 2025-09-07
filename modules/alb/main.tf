# Safe, consistent naming without regex
locals {
  derived_slug = replace(replace(lower(var.project), " ", "-"), "_", "-")
  name_slug    = coalesce(var.project_slug, local.derived_slug)

  alb_name = substr("alb-${local.name_slug}-alb", 0, 32)
  tg_name  = substr("${local.name_slug}-tg", 0, 32)
}

resource "aws_lb" "alb" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name    = local.alb_name
    Project = var.project
    Tier    = "edge"
  }
}

resource "aws_lb_target_group" "web" {
  name     = local.tg_name
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name    = local.tg_name
    Project = var.project
  }
}

resource "aws_lb_target_group_attachment" "attach" {
  for_each         = var.target_instance_ids_map
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = each.value
  port             = var.target_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
