locals {
  name = "${var.project_name}-${var.environment}-runner"

  pat_ssm_arn = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.pat_ssm_parameter_name}"

  register_script = templatefile("${path.module}/runner-register.sh.tpl", {
    pat_ssm_parameter_name = var.pat_ssm_parameter_name
    github_owner           = var.github_owner
    github_repo            = var.github_repo
  })

  user_data = templatefile("${path.module}/user-data.sh.tpl", {
    runner_version             = var.runner_version
    runner_register_script_b64 = base64encode(local.register_script)
  })
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_kms_key" "github_pat" {
  description             = "Encrypts the GitHub PAT in SSM Parameter Store for ${local.name}."
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = { Name = "${var.project_name}-github-pat" }
}

resource "aws_kms_alias" "github_pat" {
  name          = "alias/${var.project_name}-github-pat"
  target_key_id = aws_kms_key.github_pat.key_id
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "runner" {
  statement {
    sid       = "ECRGetAuthToken"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "ECRPushToProjectRepos"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    resources = var.ecr_repository_arns
  }

  statement {
    sid = "SSMReadGitHubPAT"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [local.pat_ssm_arn]
  }

  statement {
    sid       = "KMSDecryptPATKey"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.github_pat.arn]
  }
}

resource "aws_iam_role_policy" "runner" {
  name   = "runner-permissions"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.runner.json
}

resource "aws_iam_instance_profile" "this" {
  name = local.name
  role = aws_iam_role.this.name
}

resource "aws_security_group" "this" {
  name        = "${local.name}-sg"
  description = "GitHub Actions runner: no inbound; HTTPS egress only."
  vpc_id      = var.vpc_id

  egress {
    description = "HTTPS to VPC for interface endpoints (ECR, STS, SSM)."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "HTTPS to internet via NAT for github.com, ghcr.io, public image base layers."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-sg" }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.instance_type
  subnet_id                   = var.runner_subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = false

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    encrypted   = true
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }

  user_data                   = local.user_data
  user_data_replace_on_change = true

  tags = { Name = local.name }
}
