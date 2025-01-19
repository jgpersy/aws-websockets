data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../lambda_code/"
  output_path = "../lambda_code/${var.lambda_name}.zip"
  excludes    = setsubtract(fileset("../lambda_code/", "*"), ["${var.lambda_name}.py", "lambda_logging.py"])
}

resource "aws_lambda_function" "lambda" {
  function_name    = "${var.lambda_name}_${var.env}"
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = "../lambda_code/${var.lambda_name}.zip"
  runtime          = var.python_runtime
  handler          = "${var.lambda_name}.handler"
  depends_on       = [data.archive_file.lambda_zip, aws_security_group.lambda_route_sg]
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  timeout          = 10
  layers           = [aws_lambda_layer_version.redis_layer.arn]

  vpc_config {
    security_group_ids = [aws_security_group.lambda_route_sg.id]
    subnet_ids         = var.subnet_ids
  }

  environment {
    variables = {
      API_GW_ID            = var.api_gw_id
      API_GW_STAGE_NAME    = var.api_gw_stage_name
      ELASTICACHE_ENDPOINT = var.elasticache_endpoint
      LOG_LEVEL            = var.config_log_level
    }
  }
}

resource "aws_lambda_layer_version" "redis_layer" {
  filename   = "../lambda_code/redis_layer.zip"
  layer_name = "redis_layer"

  compatible_runtimes = ["python3.10"]
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id             = var.api_gw_id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.lambda.invoke_arn
  connection_type    = "INTERNET"
}

resource "aws_apigatewayv2_route" "route" {
  api_id             = var.api_gw_id
  route_key          = var.route_key
  operation_name     = var.operation_name
  target             = "integrations/${aws_apigatewayv2_integration.integration.id}"
  authorization_type = var.operation_name == "connect" ? "CUSTOM" : "NONE"
  authorizer_id      = var.authorizer_id
}

