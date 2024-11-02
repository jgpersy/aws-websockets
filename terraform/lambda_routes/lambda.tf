data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda_code/${var.lambda_name}.py"
  output_path = "../lambda_code/${var.lambda_name}.zip"

}

resource "aws_lambda_function" "lambda" {
  function_name    = var.lambda_name
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = "../lambda_code/${var.lambda_name}.zip"
  runtime          = var.python_runtime
  handler          = "${var.lambda_name}.handler"
  depends_on       = [data.archive_file.lambda_zip]
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  timeout          = 10

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamo_db_table_name
      DYNAMODB_TABLE_PKEY = var.dynamo_db_table_pkey
      API_GW_ID           = var.api_gw_id
      API_GW_STAGE_NAME   = var.api_gw_stage_name
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda_${var.lambda_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id             = var.api_gw_id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.lambda.invoke_arn
  connection_type    = "INTERNET"
}

resource "aws_apigatewayv2_route" "route" {
  api_id         = var.api_gw_id
  route_key      = var.route_key
  operation_name = var.operation_name
  target         = "integrations/${aws_apigatewayv2_integration.integration.id}"
  authorization_type = var.operation_name == "connect" ? "CUSTOM" : "NONE"
  authorizer_id = var.authorizer_id
}

resource "aws_lambda_permission" "allow_api_gateway_to_invoke_lambdas" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gw_execution_arn}/*"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment_dynamo_db" {
  policy_arn = aws_iam_policy.dynamo_db_policy.arn
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_policy" "dynamo_db_policy" {
  name        = "websockets_lamda_policy_${var.lambda_name}"
  path        = "/"
  description = ""

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:ConditionCheckItem",
          "dynamodb:BatchGetItem",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
        ]
        Effect   = "Allow"
        Resource = var.dynamo_db_table_arn
      },
      {
        Action = [
          "execute-api:ManageConnections"
        ]
        Effect   = "Allow"
        Resource = "${var.api_gw_execution_arn}/*"
      }
    ]
  })
}