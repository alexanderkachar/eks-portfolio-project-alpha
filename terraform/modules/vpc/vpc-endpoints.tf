locals {
  interface_endpoints = [
    "ecr.api",
    "ecr.dkr",
    "sts",
    "ec2",
    "elasticloadbalancing",
    "eks",
    "eks-auth",
    "ssm",
    "ssmmessages",
    "ec2messages",
    "logs",
  ]

  private_subnet_ids = [
    aws_subnet.this["private_a"].id,
    aws_subnet.this["private_b"].id,
  ]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${local.name_prefix}-vpce-s3"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.interface_endpoints)

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.name_prefix}-vpce-${replace(each.value, ".", "-")}"
  }
}
