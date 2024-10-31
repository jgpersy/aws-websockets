output "lambda_authorizer_invoke_arn" {
  value = aws_lambda_function.lambda_authorizer.invoke_arn
}