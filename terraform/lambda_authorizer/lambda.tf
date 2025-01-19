data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../lambda_code/"
  output_path = "../lambda_code/${var.lambda_name}.zip"
  excludes    = setsubtract(fileset("../lambda_code/", "*"), ["${var.lambda_name}.py", "lambda_logging.py"])
}

resource "aws_lambda_function" "lambda_authorizer" {
  function_name    = "${var.lambda_name}_${var.env}"
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = "../lambda_code/${var.lambda_name}.zip"
  runtime          = var.python_runtime
  handler          = "${var.lambda_name}.handler"
  depends_on       = [data.archive_file.lambda_zip]
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  timeout          = 10

  environment {
    variables = {
      LOG_LEVEL           = var.config_log_level
      QUERY_STRING_SECRET = var.query_string_secret
      API_KEY_SECRET      = var.api_key_secret
    }
  }
}

resource "aws_lambda_permission" "allow_api_gateway_to_invoke_lambda_authorizer" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gw_execution_arn}/*"
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