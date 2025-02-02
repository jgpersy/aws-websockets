variable "lambda_name" {
  description = "The name of the lambda function"
  type        = string
}

variable "api_gw_id" {
  description = "The id of the api gateway"
  type        = string
}

variable "api_gw_execution_arn" {
  description = "The execution arn of the api gateway"
  type        = string
}

variable "route_key" {
  description = "The route key for the api gateway route"
  type        = string
}

variable "operation_name" {
  description = "The operation name for the api gateway route"
  type        = string
}

variable "api_gw_stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
}

variable "python_runtime" {
  description = "Python runtime version"
  type        = string
}

variable "authorizer_id" {
  description = "The id of the authorizer resource"
  type        = string
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "The vpc to place lambda function in"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "The subnet ids to place lambda function in"
}

variable "elasticache_endpoint" {
  type        = string
  description = "The endpoint of the elasticache"
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