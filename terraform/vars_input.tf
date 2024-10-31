variable "api_gw_stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
  default     = "sandbox"
}

variable "python_runtime" {
    description = "The python runtime version"
    type        = string
    default     = "python3.12"
}