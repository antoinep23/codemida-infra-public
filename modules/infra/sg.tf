### ALB
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "codemida-ecs-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb" {
  for_each          = var.allowed_ips
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = {
    Name = "allow-https-to-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_to_https" {
  for_each          = var.allowed_ips
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Name = "redirect-http-to-https-alb"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "-1" # all ports all protocols

  tags = {
    Name = "allow-all-to-app"
  }
}

### App
resource "aws_security_group" "app" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "codemida-ecs-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "-1"

  tags = {
    Name = "allow-all-from-alb"
  }
}

resource "aws_vpc_security_group_egress_rule" "app" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = "allow-all"
  }
}