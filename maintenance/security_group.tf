# ================================================================================
# Security Group for Bastion
# ================================================================================
resource "aws_security_group" "bastion" {
  name        = "${local.project}-${local.env}-bastion-sg"
  description = "Security Group for ${local.project}-${local.env} Bastion"
  vpc_id      = aws_vpc.maintenance.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      for ip in var.maintenance_ips :
      ip
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "tcp"
    cidr_blocks = [
      local.default_gateway_cidr,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-bastion-sg"
  }
}
