output "salesapi_gw_url" {
  description = "Sales API Gateway URL"
  value = aws_apigatewayv2_api.salesapi-tf-gw.api_endpoint
}

# output "factory_gw_url" {
#   description = "Factory API Gateway URL"
#   value = aws_apigatewayv2_api. .api_endpoint
# }

output "increase_gw_url" {
  description = "increase API Gateway URL"
  value = aws_apigatewayv2_api.increase-tf-gw.api_endpoint
}