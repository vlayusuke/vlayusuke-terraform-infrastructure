# ===============================================================================
# EC2 Instance Profile
# ===============================================================================
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.project}-${local.env}-iam-bastion-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role" "bastion" {
  name               = "${local.project}-${local.env}-iam-bastion-role"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-bastion-role"
  }
}

data "aws_iam_policy_document" "bastion_assume" {
  statement {
    sid    = "EC2Assume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.project}-${local.env}-iam-bastion-role"
      ]
    }
  }
}

resource "aws_iam_policy" "bastion" {
  name   = "${local.project}-${local.env}-iam-bastion-policy"
  policy = data.aws_iam_policy_document.bastion.json

  tags = {
    Name = "${local.project}-${local.env}-iam-bastion-policy"
  }
}

data "aws_iam_policy_document" "bastion" {
  statement {
    sid    = "GetConfigFromS3"
    effect = "Allow"
    actions = [
      "s3:Get*",
    ]
    resources = [
      "${data.terraform_remote_state.production.outputs.s3_bucket_bastion_arn}/*",
    ]
  }

  statement {
    sid    = "S3FullAccess"
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
    ]
    resources = [
      aws_cloudwatch_log_group.bastion.arn,
      "${aws_cloudwatch_log_group.bastion.arn}:log-stream:*",
    ]
  }

  statement {
    sid    = "PutMetricData"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.id
  policy_arn = aws_iam_policy.bastion.arn
}

resource "aws_iam_role_policy_attachment" "bastion_to_AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.bastion.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
