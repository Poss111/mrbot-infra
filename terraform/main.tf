resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_cidr
  map_public_ip_on_launch = true
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_network_acl_rule" "allow_http_inbound" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_route_cidr
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "allow_https_inbound" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.public_route_cidr
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "allow_all_outbound" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.public_route_cidr
}

resource "aws_network_acl_association" "public" {
  subnet_id      = aws_subnet.public.id
  network_acl_id = aws_network_acl.main.id
}

resource "aws_security_group" "mr-bot-sg" {
  name        = "mr-bot-sg"
  description = "Security group for VPC endpoint to Secrets Manager"
  vpc_id      = aws_vpc.main.id

  # Ingress rule to allow traffic from specific trusted CIDR ranges (optional)
  ingress {
    description = "Allow HTTPS traffic from trusted CIDRs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_cidr
    ]
  }

  # Outbound rules (default allows all outbound traffic)
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1" # All traffic
    cidr_blocks = [
      var.vpc_cidr
    ]
  }

  tags = {
    Name = "mr-bot-sg"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.public.id]
  security_group_ids = [aws_security_group.mr-bot-sg.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.public.id]
  security_group_ids = [aws_security_group.mr-bot-sg.id]
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.public.id]
  security_group_ids = [aws_security_group.mr-bot-sg.id]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.public.id]
  security_group_ids = [aws_security_group.mr-bot-sg.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public.id]
}
