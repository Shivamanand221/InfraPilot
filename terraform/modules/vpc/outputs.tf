output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_app_subnet_ids" {
  value = [
    aws_subnet.private_app_a.id,
    aws_subnet.private_app_b.id
  ]
}

output "private_db_subnet_ids" {
  value = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id
  ]
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_app_route_table_id" {
  value = aws_route_table.private_app.id
}

output "private_db_route_table_id" {
  value = aws_route_table.private_db.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}