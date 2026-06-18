output "public_ips" {
  value = [for i in aws_instance.template_instance : i.public_ip]
}

output "public_dns" {
  value = [for i in aws_instance.template_instance : i.public_dns]
}

output "instance_ids" {
  value = [for i in aws_instance.template_instance : i.id]
}

output "instance_ids_map" {
  value = { for k, i in aws_instance.template_instance : k => i.id }
}
