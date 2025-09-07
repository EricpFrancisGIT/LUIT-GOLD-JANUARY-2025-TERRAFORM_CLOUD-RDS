output "public_ips" {
  value = [for i in aws_instance.web : i.public_ip]
}

output "public_dns" {
  value = [for i in aws_instance.web : i.public_dns]
}

output "instance_ids" {
  value = [for i in aws_instance.web : i.id]
}

output "instance_ids_map" {
  value = { for k, i in aws_instance.web : k => i.id }
}
