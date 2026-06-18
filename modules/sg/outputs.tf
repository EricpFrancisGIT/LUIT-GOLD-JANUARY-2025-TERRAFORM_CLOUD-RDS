output "alb_sg_id" { value = aws_security_group.template_alb.id }
output "web_sg_id" { value = aws_security_group.template_web.id }
output "db_sg_id" { value = aws_security_group.template_db.id }
