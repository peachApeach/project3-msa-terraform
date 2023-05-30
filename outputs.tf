output "salesapi_gw_url" {
  description = "Sales API Gateway URL"
  value = aws_apigatewayv2_api.salesapi-tf-gw.api_endpoint
}