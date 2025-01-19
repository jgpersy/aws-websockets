variable "api_gw_stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
  default     = "websockets-stage"
}

variable "python_runtime" {
  description = "The python runtime version"
  type        = string
  default     = "python3.10"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "The subnet ids for elasticache"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "The vpc id"
}

variable "log_level" {
  description = "The log level for the lambda"
  type        = string
  default     = "DEBUG"
}