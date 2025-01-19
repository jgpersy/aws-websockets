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

variable "config_log_level" {
  description = "The log level for the lambda"
  type        = string
  default     = "INFO"
}

variable "env" {
  description = "The environment the project is in"
  type        = string
}

variable "query_string_secret" {}
variable "api_key_secret" {}