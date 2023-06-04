variable "stock_lambda_name" {
  description = "stock_lambda_name"
  type = string
  default = "stock-tf"
}

variable "stock_increase_lambda_name" {
  description = "stock_increase_lambda_name"
  type = string
  default = "stock-increase-tf"
}

variable "factory_lambda_name" {
  description = "factory_lambda_name"
  type = string
  default = "factory-tf"
}

variable "factory_gw_name" {
  description = "factory_gw_name"
  type = string
  default = "factory-tf-gw"
}

variable "stock_increase_gw_name" {
  description = "stock_increase_gw_name"
  type = string
  default = "increase-tf-gw"
}