# Outputs aligned with exact resource names above
output "dns_name" { value = aws_lb.template.dns_name }
output "arn" { value = aws_lb.template.arn }
output "tg_arn" { value = aws_lb_target_group.template-targetgroup_web.arn }
output "listener_arn" { value = aws_lb_listener.template_listener_http.arn }
output "name" { value = aws_lb.template.name }
