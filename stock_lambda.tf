##############################################################
# lambda
##############################################################
# 1) lambda 함수 내용을 handler.js에 작성 후 압축 
data "archive_file" "stock_lambda_zip" {
    type = "zip"

    source_dir = "${path.module}/src"
    output_path = "${path.module}/stock_src.zip"
}

# 2) lambda function 선언 
resource "aws_lambda_function" "stock-lambda" {
  function_name = var.stock_lambda_name
  description = "stock Lambda function - v.tf"

  runtime = "nodejs14.x"
  handler = "stock_handler.handler"

  filename = data.archive_file.stock_lambda_zip.output_path
  source_code_hash = data.archive_file.stock_lambda_zip.output_base64sha256

  role = aws_iam_role.salesapilambda_exec.arn

  depends_on = [ aws_cloudwatch_log_group.stock-logs ]

  environment {
    variables = {
        FACTORY_URL = "${aws_apigatewayv2_api.factory-tf-gw.api_endpoint}"
    }
  }

}

# 3) CloudWatch 생성 
resource "aws_cloudwatch_log_group" "stock-logs" {
  # 양식 맞춰야함
  name = "/aws/lambda/${var.stock_lambda_name}"
  tags = {"name":"/aws/lambda/${var.stock_lambda_name}"}
}

# 4) SQS Trigger
resource "aws_lambda_event_source_mapping" "stock_lambda_trigger" {
  event_source_arn = aws_sqs_queue.stock_queue.arn
  function_name = aws_lambda_function.stock-lambda.arn
}