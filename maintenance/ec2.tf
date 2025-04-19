# ================================================================================
# EC2 Instance for Bastion
# ================================================================================
resource "aws_instance" "ec2_bastion" {
  ami                         = data.aws_ssm_parameter.arm64_al2023_ami.value
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.ec2_bastion.key_name
  disable_api_stop            = false
  disable_api_termination     = false
  monitoring                  = true
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.maintenance_public[0].id
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 256

    tags = {
      Name = "${local.project}-${local.env}-ec2-bastion-root-ebs"
    }
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }

  tags = {
    Name      = "${local.project}-${local.env}-ec2-bastion"
    inspector = "true"
  }
}


# ================================================================================
# EIP for Bastion
# ================================================================================
resource "aws_eip" "ec2_bastion" {
  instance = aws_instance.ec2_bastion.id
  domain   = "vpc"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "${local.project}-${local.env}-ec2-bastion-eip"
  }
}


# ================================================================================
# Key Pair
# ================================================================================
resource "aws_key_pair" "ec2_bastion" {
  key_name   = "${local.project}-${local.env}-ec2-bastion-key"
  public_key = var.aws_key_pub_bastion

  tags = {
    Name = "${local.project}-${local.env}-ec2-bastion-key"
  }
}


# ================================================================================
# SSM Parameter
# ================================================================================
data "aws_ssm_parameter" "arm64_al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

data "aws_ssm_parameter" "x86_64_al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# ================================================================================
# EBS Volume default encrypted
# ================================================================================
resource "aws_ebs_encryption_by_default" "ec2_bastion" {
  enabled = true
}
