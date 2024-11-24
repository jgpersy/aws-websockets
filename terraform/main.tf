provider "aws" {
  region = "eu-west-1"
}

locals {
  lambdas = {
    "connect" : {
      operation_name : "connect"
      route_key : "$connect",
      lambda_name : "websockets_connect"
    },
    "disconnect" : {
      operation_name : "disconnect"
      route_key : "$disconnect",
      lambda_name : "websockets_disconnect"
    },
    "default" : {
      operation_name : "default"
      route_key : "$default",
      lambda_name : "websockets_default"
    },
    "sendmessage" : {
      operation_name : "sendmessage"
      route_key : "sendmessage",
      lambda_name : "websockets_sendmessage"
    }
    "subscribe" : {
      operation_name : "subscribe"
      route_key : "subscribe",
      lambda_name : "websockets_subscribe"
    }
  }
}

module "lambda_authorizer" {
  source               = "./lambda_authorizer"
  lambda_name          = "websockets_authorizer"
  python_runtime       = var.python_runtime
  api_gw_execution_arn = aws_apigatewayv2_api.websockets_api.execution_arn
}

module "lambda_routes" {
  source               = "./lambda_routes"
  for_each             = local.lambdas
  python_runtime       = var.python_runtime
  lambda_name          = each.value.lambda_name
  api_gw_id            = aws_apigatewayv2_api.websockets_api.id
  api_gw_execution_arn = aws_apigatewayv2_api.websockets_api.execution_arn
  route_key            = each.value.route_key
  operation_name       = each.value.operation_name
  api_gw_stage_name    = var.api_gw_stage_name
  authorizer_id        = aws_apigatewayv2_authorizer.authorizer.id
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
  elasticache_endpoint = aws_elasticache_serverless_cache.redis.endpoint[0]["address"]
}

