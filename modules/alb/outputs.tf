# Outputs aligned with exact resource names above
output "dns_name" { value = aws_lb.alb.dns_name }
output "arn" { value = aws_lb.alb.arn }
output "tg_arn" { value = aws_lb_target_group.web.arn }
output "listener_arn" { value = aws_lb_listener.http.arn }
output "name" { value = aws_lb.alb.name }
