# ===============================================================================
# VPC Endpoint (ECR - Docker)
# ===============================================================================
resource "aws_vpc_endpoint" "ecr_docker" {
  vpc_id              = aws_vpc.production.id
  service_name        = "com.amazonaws.${local.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.ecr_vpce.id,
  ]

  subnet_ids = [
    for subnet in aws_subnet.production_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-vpce-ecr-dkr"
  }
}


# ===============================================================================
# VPC Endpoint (ECR - API)
# ===============================================================================
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.production.id
  service_name        = "com.amazonaws.${local.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.ecr_vpce.id,
  ]

  subnet_ids = [
    for subnet in aws_subnet.production_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-vpce-ecr-api"
  }
}


# ===============================================================================
# VPC Endpoint (S3 Bucket)
# ===============================================================================
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.production.id
  service_name      = "com.amazonaws.${local.region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${local.project}-${local.env}-vpce-s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway" {
  count           = length(local.availability_zones)
  vpc_endpoint_id = aws_vpc_endpoint.s3_gateway.id
  route_table_id  = aws_route_table.production_private[count.index].id
}
