# ===============================================================================
# IAM for Deployment
# ===============================================================================
resource "aws_iam_role" "github_actions_deploy" {
  name               = "${local.project}-${local.env}-iam-github-actions-deploy-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.github_actions_deploy_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-deploy-role"
  }
}

data "aws_iam_policy_document" "github_actions_deploy_assume" {
  statement {
    sid    = "OIDCFederate"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.repository_name}/*",
      ]
    }
  }
}

resource "aws_iam_policy" "github_actions_deploy" {
  name   = "${local.project}-${local.env}-iam-github-actions-deploy-policy"
  policy = data.aws_iam_policy_document.github_actions_deploy.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-deploy-policy"
  }
}

data "aws_iam_policy_document" "github_actions_deploy" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${local.project}-${local.env}-*",
      "arn:aws:s3:::${local.project}-${local.env}-*/*",
      "arn:aws:s3:::mcury-*",
    ]
  }
}

resource "aws_iam_policy_attachment" "github_actions_deploy" {
  name = "${local.project}-${local.env}-iam-github-actions-deploy-attachment"
  roles = [
    aws_iam_role.github_actions_deploy.name,
  ]
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}


# ===============================================================================
# IAM for Source Code Backup
# ===============================================================================
resource "aws_iam_role" "github_actions_backup" {
  name               = "${local.project}-${local.env}-iam-github-actions-backup-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.github_actions_backup_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-backup-role"
  }
}

data "aws_iam_policy_document" "github_actions_backup_assume" {
  statement {
    sid    = "OIDCFederate"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.repository_name}/*",
      ]
    }
  }
}

resource "aws_iam_policy" "github_actions_backup" {
  name   = "${local.project}-${local.env}-iam-github-actions-backup-policy"
  policy = data.aws_iam_policy_document.github_actions_backup.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-backup-policy"
  }
}

data "aws_iam_policy_document" "github_actions_backup" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${local.project}-${local.env}-*",
      "arn:aws:s3:::${local.project}-${local.env}-*/*",
      "arn:aws:s3:::terraform-*",
    ]
  }
}

resource "aws_iam_policy_attachment" "github_actions_backup" {
  name = "${local.project}-${local.env}-iam-github-actions-backup-attachment"
  roles = [
    aws_iam_role.github_actions_backup.name,
  ]
  policy_arn = aws_iam_policy.github_actions_backup.arn
}


# ================================================================================
# EC2 Instance Profile for Bastion
# ================================================================================
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
      "${aws_s3_bucket.bastion.arn}/*"
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
