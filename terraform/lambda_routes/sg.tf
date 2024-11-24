resource "aws_security_group" "lambda_route_sg" {
  name        = "lambda-route-${var.lambda_name}-sg"
  description = "${var.lambda_name} security group"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.lambda_route_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

