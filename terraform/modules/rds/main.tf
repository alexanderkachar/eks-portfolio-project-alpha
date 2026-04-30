locals {
  name             = "${var.project_name}-${var.environment}-postgres"
  ssm_param_prefix = "/${var.project_name}/rds"
}

resource "aws_kms_key" "rds" {
  description             = "RDS storage + SSM SecureString encryption for ${local.name}."
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = { Name = "${local.name}-kms" }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${local.name}"
  target_key_id = aws_kms_key.rds.key_id
}

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

resource "aws_db_subnet_group" "this" {
  name       = local.name
  subnet_ids = var.db_subnet_ids
  tags       = { Name = local.name }
}

resource "aws_security_group" "this" {
  name        = "${local.name}-sg"
  description = "Postgres: ingress 5432 from cluster nodes only; no egress."
  vpc_id      = var.vpc_id

  tags = { Name = "${local.name}-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "from_cluster" {
  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.cluster_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "Postgres from EKS cluster nodes."

  tags = { Name = "${local.name}-from-cluster" }
}

resource "aws_db_instance" "this" {
  identifier = local.name

  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage_gb
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  db_name  = var.db_name
  username = var.master_username
  password = random_password.master.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  apply_immediately          = false
  auto_minor_version_upgrade = false

  tags = { Name = local.name }
}

resource "aws_ssm_parameter" "master_password" {
  name   = "${local.ssm_param_prefix}/master-password"
  type   = "SecureString"
  key_id = aws_kms_key.rds.id
  value  = random_password.master.result

  tags = { Name = "${local.name}-master-password" }
}

resource "aws_ssm_parameter" "host" {
  name  = "${local.ssm_param_prefix}/host"
  type  = "String"
  value = aws_db_instance.this.address

  tags = { Name = "${local.name}-host" }
}

resource "aws_ssm_parameter" "port" {
  name  = "${local.ssm_param_prefix}/port"
  type  = "String"
  value = tostring(aws_db_instance.this.port)

  tags = { Name = "${local.name}-port" }
}

resource "aws_ssm_parameter" "database" {
  name  = "${local.ssm_param_prefix}/database"
  type  = "String"
  value = aws_db_instance.this.db_name

  tags = { Name = "${local.name}-database" }
}

resource "aws_ssm_parameter" "username" {
  name  = "${local.ssm_param_prefix}/username"
  type  = "String"
  value = var.master_username

  tags = { Name = "${local.name}-username" }
}
