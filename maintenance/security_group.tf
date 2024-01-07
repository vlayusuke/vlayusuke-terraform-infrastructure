# ===============================================================================
# Security Group for Bastion
# ===============================================================================
resource "aws_security_group" "bastion" {
  name        = "${local.project}-${local.env}-bastion-sg"
  description = "Security Group for ${local.project}-${local.env} bastion"
  vpc_id      = aws_vpc.maintenance.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      var.maintenance_ips,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project}-${local.env}-bastion-sg"
  }
}
