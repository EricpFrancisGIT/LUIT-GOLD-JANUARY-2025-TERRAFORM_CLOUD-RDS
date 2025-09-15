# Outputs aligned with exact resource names above
output "dns_name" { value = aws_lb.city_of_anaheim_alb.dns_name }
output "arn" { value = aws_lb.city_of_anaheim_alb.arn }
output "tg_arn" { value = aws_lb_target_group.city_of_anaheim_web.arn }
output "listener_arn" { value = aws_lb_listener.city_of_anaheim_http.arn }
output "name" { value = aws_lb.city_of_anaheim_alb.name }
