terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

//region 설정
provider "aws" {
  region = "ap-northeast-2"
}


##############################################################
# lambda
##############################################################
# 1) lambda 함수 내용을 handler.js에 작성 후 압축  
data "archive_file" "lambda_zip" {
    type = "zip"

    source_dir = "${path.module}/src"
    output_path = "${path.module}/src.zip"
}

# 2) lambda function 선언 
resource "aws_lambda_function" "sales-api-lambda" {
  function_name = "sales-api-lambda-tf"
  description = "Sales api gateway function - v.tf"

  runtime = "nodejs14.x"
  handler = "handler.handler"

  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.salesapilambda_exec.arn

  depends_on = [ aws_cloudwatch_log_group.salesapi-logs ]

}

resource "aws_cloudwatch_log_group" "salesapi-logs" {
  name = "SalesAPI-tf-logs"
}

resource "aws_iam_role" "salesapilambda_exec" {
  name = "SalesAPI-Exec"

  # 필수 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
            Service = "lambda.amazonaws.com"
        }
    }]
  })

}

resource "aws_iam_policy" "salesapi-role" {
  name = "SalesAPI-ap-notrheast-2-lambdaRole"
  // 공백 무시 
  policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogStream",
            "logs:TagResource",
            "logs:CreateLogGroup",
            "logs:PutLogsEvents"
        ],
        "Resource": "${aws_cloudwatch_log_group.salesapi-logs.arn}"
    }]
  }
POLICY

}

resource "aws_iam_role_policy_attachment" "salesapi-policy" {
  role = aws_iam_role.salesapilambda_exec.name
  policy_arn = aws_iam_policy.salesapi-role.arn
}

##############################################################
# Sales API Gateway Trigger
##############################################################
# version 1은 REST API를 생성할 때 사용하며 version 2는 WebSocket 및 HTTP API를 생성하고 배포하는데 사용 
resource "aws_apigatewayv2_api" "salesapi-tf-gw" {
  name = "salesapi-tf-gw"
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
resource "aws_apigatewayv2_stage" "salesapi_stage" {
  api_id = aws_apigatewayv2_api.salesapi-tf-gw.id

  name = "$default"
  auto_deploy = "false"

}

# Lambda 함수를 사용하도록 API 게이트웨이를 구성 
resource "aws_apigatewayv2_integration" "salesapi_integration" {
  api_id = aws_apigatewayv2_api.salesapi-tf-gw.id

  integration_uri = aws_lambda_function.sales-api-lambda.invoke_arn
  integration_type = "AWS_PROXY"
}

# HTTP 요청을 Lambda 함수에 매핑
resource "aws_apigatewayv2_route" "salesapi_route" {
    api_id = aws_apigatewayv2_api.salesapi-tf-gw.id
    route_key = "$default"
    # 경로에 대한 대상 integrations/{IntegrationID}
    target = "integrations/${aws_apigatewayv2_integration.salesapi_integration.id}"
  
}

# Lambda 함수를 호출할 수 있는 API Gateway 권한 부여 
resource "aws_lambda_permission" "salesapi_gwpm" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sales-api-lambda.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.salesapi-tf-gw.execution_arn}/*/*"
}