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

variable "dynamo_db_table_arn" {
  description = "The arn of the dynamo db table"
  type        = string
}

variable "dynamo_db_table_name" {
  description = "The name of the dynamo db table"
  type        = string
}

variable "dynamo_db_table_pkey" {
  description = "The primary key of the dynamo db table"
  type        = string
}

variable "api_gw_stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
}

variable "python_runtime" {
  description = "Python runtime version"
  type = string
}

variable "authorizer_id" {
    description = "The id of the authorizer resource"
    type        = string
}

variable "vpc_id" {
    type = string
    default = ""
    description = "The vpc to place lambda function in"
}

variable "subnet_ids" {
    type = list(string)
    default = []
    description = "The subnet ids to place lambda function in"
}

variable "elasticache_arn" {
    type = string
    description = "The arn of the elasticache"
}