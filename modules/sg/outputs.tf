output "alb_sg_id" { value = aws_security_group.city_of_anaheim_alb.id }
output "web_sg_id" { value = aws_security_group.city_of_anaheim_web.id }
output "db_sg_id" { value = aws_security_group.city_of_anaheim_db.id }
