resource "aws_dynamodb_table" "api_gw_connection_ids" {
  name         = "ConnectionIds"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ConnectionId"

  attribute {
    name = "ConnectionId"
    type = "S"
  }

  tags = {
    Name = "api_gw_websocket_connection_ids"
  }
}

resource "aws_elasticache_serverless_cache" "websockets_cache" {
  engine = "memcached"
  name   = "websockets-cache"
  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  description          = "Websockets cache"
  major_engine_version = "1.6"
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
  from_port         = 11211
  protocol          = "tcp"
  security_group_id = aws_security_group.websockets_elasticache_sg.id
  to_port           = 11211
  type              = "ingress"
  source_security_group_id = each.value.lambda_sg_id
}