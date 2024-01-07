# ===============================================================================
# VPC
# ===============================================================================
resource "aws_vpc" "main" {
  cidr_block                       = local.vpc_cidr_block
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${local.project}-${local.env}-main-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project}-${local.env}-main-igw"
  }
}

resource "aws_flow_log" "main_s3" {
  log_destination      = aws_s3_bucket.vpc_flow_log.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

resource "aws_route" "main_to_maintenance" {
  route_table_id            = data.terraform_remote_state.maintenance.outputs.maintenance_route_table_id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.maintenance.id
}


# ===============================================================================
# VPC Peering
# ===============================================================================
resource "aws_vpc_peering_connection" "maintenance" {
  peer_vpc_id = aws_vpc.main.id
  vpc_id      = data.terraform_remote_state.maintenance.outputs.maintenance_vpc_id

  tags = {
    Name = "${local.project}-${local.env}-maintenance-vpc-peering"
  }
}


# ===============================================================================
# Public Subnet
# ===============================================================================
resource "aws_subnet" "public" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project}-${local.env}-public-subnet-${local.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "public" {
  count  = length(local.availability_zones)
  vpc_id = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      route,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-public-subnet-rtb-${local.availability_zones[count.index]}"
  }
}

resource "aws_route" "public_to_default" {
  route_table_id         = aws_subnet.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "public_to_maintenance" {
  route_table_id            = aws_subnet.public.id
  destination_cidr_block    = data.terraform_remote_state.maintenance.outputs.maintenance_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.maintenance.id
}

resource "aws_route_table_association" "public" {
  count          = length(local.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# ===============================================================================
# Private Subnet
# ===============================================================================
resource "aws_subnet" "private" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + length(local.availability_zones))
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.project}-${local.env}-private-subnet-${local.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "private" {
  count  = length(local.availability_zones)
  vpc_id = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      route,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-private-subnet-rtb-${local.availability_zones[count.index]}"
  }
}

resource "aws_route" "private_to_nat_gw" {
  count                  = length(local.availability_zones)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route" "private_to_maintenance" {
  count                     = length(local.availability_zones)
  route_table_id            = aws_route_table.private[count.index].id
  destination_cidr_block    = data.terraform_remote_state.maintenance.outputs.maintenance_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.maintenance.id
}

resource "aws_route_table_association" "private" {
  count          = length(local.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


# ===============================================================================
# NAT Gateway
# ===============================================================================
resource "aws_nat_gateway" "main" {
  count         = length(local.availability_zones)
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat_gateway[count.index].id

  tags = {
    Name = "${local.project}-${local.env}-nat-gateway-${local.availability_zones[count.index]}"
  }
}


# ===============================================================================
# EIP for NAT Gateway
# ===============================================================================
resource "aws_eip" "nat_gateway" {
  count  = length(local.availability_zones)
  domain = "vpc"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "${local.project}-${local.env}-nat-gateway-eip-${local.availability_zones[count.index]}"
  }
}
