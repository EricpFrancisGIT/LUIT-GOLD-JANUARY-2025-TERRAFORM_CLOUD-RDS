output "ec2_public_ips" {
  description = "Public IPs for the two web servers"
  value       = module.ec2.public_ips
}


output "ec2_urls" {
  description = "HTTP URLs for EC2 instances"
  value       = [for ip in module.ec2.public_ips : "http://${ip}"]
}


output "rds_endpoint" {
  description = "RDS endpoint hostname"
  value       = module.rds.endpoint
}


output "rds_port" {
  value       = module.rds.port
  description = "RDS port"
}

output "alb_dns_name" { value = module.alb.dns_name }
output "alb_url" { value = "http://${module.alb.dns_name}" }
output "web_public_ips" {
  description = "Public IPs for the two web servers"
  value       = module.ec2.public_ips
}

