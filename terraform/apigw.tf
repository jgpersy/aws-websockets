resource "aws_apigatewayv2_api" "websockets_api" {
  name                       = "websockets-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id        = aws_apigatewayv2_api.websockets_api.id
  name          = var.api_gw_stage_name
  deployment_id = aws_apigatewayv2_deployment.deployment.id

  default_route_settings {
    logging_level          = "INFO"
    throttling_burst_limit = 100
    throttling_rate_limit  = 100
  }
}

resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id           = aws_apigatewayv2_api.websockets_api.id
  authorizer_type  = "REQUEST"
  authorizer_uri   = module.lambda_authorizer.lambda_authorizer_invoke_arn
  name             = "websockets-authorizer"
  identity_sources = ["route.request.querystring.QueryString1"]
}

resource "aws_apigatewayv2_deployment" "deployment" {
  api_id      = aws_apigatewayv2_api.websockets_api.id
  description = "Deployment for the API ${timestamp()}"
  depends_on  = [module.lambda_routes, module.lambda_authorizer, aws_apigatewayv2_authorizer.authorizer]

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(join(",", tolist(
      [jsonencode(module.lambda_authorizer), jsonencode(module.lambda_routes)]
    )))
  }
}




