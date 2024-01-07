# ===============================================================================
# Outputs from Maintenance
# ===============================================================================
output "maintenance_vpc_id" {
  value = aws_vpc.maintenance.id
}

output "maintenance_vpc_cidr_block" {
  value = aws_vpc.maintenance.cidr_block
}

output "maintenance_route_table_id" {
  value = aws_route_table.maintenance_public.id
}
