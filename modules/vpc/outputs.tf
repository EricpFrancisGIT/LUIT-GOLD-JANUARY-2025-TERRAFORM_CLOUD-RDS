output "vpc_id" {
  value = aws_vpc.city_of_anaheim.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.city_of_anaheim_public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.city_of_anaheim_private : s.id]
}
output "public_route_table_id" {
  value = aws_route_table.city_of_anaheim_public.id
}