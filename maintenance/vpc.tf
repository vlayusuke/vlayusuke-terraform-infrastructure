# ================================================================================
# VPC
# ================================================================================
resource "aws_vpc" "maintenance" {
  cidr_block                       = local.vpc_cidr_block
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${local.project}-${local.env}-maintenance-vpc"
  }
}

resource "aws_internet_gateway" "maintenance" {
  vpc_id = aws_vpc.maintenance.id

  tags = {
    Name = "${local.project}-${local.env}-maintenance-igw"
  }
}


# ================================================================================
# Public Subnet
# ================================================================================
resource "aws_subnet" "maintenance_public" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.maintenance.id
  cidr_block              = cidrsubnet(aws_vpc.maintenance.cidr_block, 4, count.index)
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project}-${local.env}-maintenance-pubsub-${local.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "maintenance_public" {
  vpc_id = aws_vpc.maintenance.id

  lifecycle {
    ignore_changes = [
      route,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-maintenance-pubsub-rtb"
  }
}

resource "aws_route" "maintenance_default_gw" {
  route_table_id         = aws_route_table.maintenance_public.id
  destination_cidr_block = local.default_gateway_cidr
  gateway_id             = aws_internet_gateway.maintenance.id
}

resource "aws_route_table_association" "maintenance_public" {
  count          = length(local.availability_zones)
  subnet_id      = aws_subnet.maintenance_public[count.index].id
  route_table_id = aws_route_table.maintenance_public.id
}
