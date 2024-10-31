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

module "lambda_routes" {
  source               = "./lambda_routes"
  for_each             = local.lambdas
  python_runtime       = var.python_runtime
  lambda_name          = each.value.lambda_name
  api_gw_id            = aws_apigatewayv2_api.websockets_api.id
  api_gw_execution_arn = aws_apigatewayv2_api.websockets_api.execution_arn
  route_key            = each.value.route_key
  operation_name       = each.value.operation_name
  dynamo_db_table_arn  = aws_dynamodb_table.api_gw_connection_ids.arn
  dynamo_db_table_name = aws_dynamodb_table.api_gw_connection_ids.name
  dynamo_db_table_pkey = aws_dynamodb_table.api_gw_connection_ids.hash_key
  api_gw_stage_name    = var.api_gw_stage_name
}

# module "lambda_authorizer" {
#   source               = "./lambda_authorizer"
#   lambda_name          = "websockets_authorizer"
#   python_runtime       = var.python_runtime
#   api_gw_execution_arn = aws_apigatewayv2_api.websockets_api.execution_arn
# }