resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
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

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.public.id]
  security_group_ids = [aws_security_group.sg.id]

  private_dns_enabled = true
}
