resource "aws_elasticache_serverless_cache" "redis" {
  engine = "redis"
  name   = "websockets-cache"
  cache_usage_limits {
    data_storage {
      maximum = 5
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  major_engine_version     = "7"
  security_group_ids   = [aws_security_group.websockets_elasticache_sg.id]
  subnet_ids           = var.subnet_ids
}

resource "aws_security_group" "websockets_elasticache_sg" {
  name        = "websockets-elasticache-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "lambda_route_inbound" {
  for_each = module.lambda_routes
  from_port         = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.websockets_elasticache_sg.id
  to_port           = 6379
  type              = "ingress"
  source_security_group_id = each.value.lambda_sg_id
}