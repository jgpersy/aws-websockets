variable "lambda_name" {
    description = "The name of the lambda function"
    type        = string
}

variable "python_runtime" {
    description = "The python runtime version"
    type        = string
}

variable "api_gw_execution_arn" {
  description = "The execution arn of the api gateway"
  type        = string
}