##############################################################
# lambda
##############################################################
# 1) lambda 함수 내용을 handler.js에 작성 후 압축 
data "archive_file" "increase_lambda_zip" {
    type = "zip"

    source_dir = "${path.module}/src"
    output_path = "${path.module}/stock_increase_src.zip"
}

# 2) lambda function 선언 
resource "aws_lambda_function" "stock-increase-lambda" {
  function_name = var.stock_increase_lambda_name
  description = "stock increase Lambda function - v.tf"

  runtime = "nodejs14.x"
  handler = "stock_increase_handler.handler"

  filename = data.archive_file.stock_lambda_zip.output_path
  source_code_hash = data.archive_file.stock_lambda_zip.output_base64sha256

  role = aws_iam_role.salesapilambda_exec.arn

  depends_on = [ aws_cloudwatch_log_group.stock-increase-logs ]

}


# 3) CloudWatch 생성 
resource "aws_cloudwatch_log_group" "stock-increase-logs" {
  # 양식 맞춰야함
  name = "/aws/lambda/${var.stock_increase_lambda_name}"
  tags = {"name":"/aws/lambda/${var.stock_increase_lambda_name}"}
}


##############################################################
# Stock Increase API Gateway Trigger
##############################################################
# version 1은 REST API를 생성할 때 사용하며 version 2는 WebSocket 및 HTTP API를 생성하고 배포하는데 사용 
resource "aws_apigatewayv2_api" "increase-tf-gw" {
  name = var.stock_increase_gw_name
  protocol_type = "HTTP"

  # HTTP 구성에만 사용 가능 
  cors_configuration {
    # 아래 옵션들은 모두 선택사항이므로 필요한 옵션을 지정 
    allow_credentials = false                               # CORS 자격 증명 포함 여부
    allow_headers = [  ]                                    # 허용되는 HTTP header 집합 
    allow_methods = [ "*" ]                                 # 허용되는 메서드 집합 
    allow_origins = [ "*" ]                                 # 허용되는 origin 집합
    expose_headers = [ ]                                    # 노출되는 header 집합
    max_age = 0                                             # 브라우저가 실행 전 요청 결과를 캐시해야하는 시간(초)
  }
}

# API 게이트웨이에 대한 어플리케이션 단계를 설정
resource "aws_apigatewayv2_stage" "increase_stage" {
  api_id = aws_apigatewayv2_api.increase-tf-gw.id

  name = "$default"
  auto_deploy = "true"

}

# Lambda 함수를 사용하도록 API 게이트웨이를 구성 
resource "aws_apigatewayv2_integration" "increase_integration" {
  api_id = aws_apigatewayv2_api.increase-tf-gw.id

  integration_uri = aws_lambda_function.stock-increase-lambda.invoke_arn
  integration_type = "AWS_PROXY"
}

# HTTP 요청을 Lambda 함수에 매핑
resource "aws_apigatewayv2_route" "increase_route" {
    api_id = aws_apigatewayv2_api.increase-tf-gw.id
    route_key = "$default"
    # 경로에 대한 대상 integrations/{IntegrationID}
    target = "integrations/${aws_apigatewayv2_integration.increase_integration.id}"
  
}

# Lambda 함수를 호출할 수 있는 API Gateway 권한 부여 
resource "aws_lambda_permission" "increase_gwpm" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stock-increase-lambda.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.increase-tf-gw.execution_arn}/*/*"
}