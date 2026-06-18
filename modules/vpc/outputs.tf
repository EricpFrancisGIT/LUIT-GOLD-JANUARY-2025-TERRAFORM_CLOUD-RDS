output "vpc_id" {
  value = aws_vpc.template.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.template_public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.template_private : s.id]
}
output "public_route_table_id" {
  value = aws_route_table.template_public.id
}
output "private_route_table_id" {
  value = aws_route_table.template_private.id
}