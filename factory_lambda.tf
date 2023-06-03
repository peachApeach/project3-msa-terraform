##############################################################
# lambda
##############################################################
# 1) lambda 함수 내용을 handler.js에 작성 후 압축 
data "archive_file" "factory_zip" {
    type = "zip"

    source_dir = "${path.module}/src"
    output_path = "${path.module}/factory_src.zip"
}

# 2) lambda function 선언 
resource "aws_lambda_function" "factory-lambda" {
  function_name = var.factory_lambda_name
  description = "factory Lambda function - v.tf"

  runtime = "nodejs14.x"
  handler = "factory_api_handler.handler"

  filename = data.archive_file.factory_zip.output_path
  source_code_hash = data.archive_file.factory_zip.output_base64sha256

  role = aws_iam_role.salesapilambda_exec.arn

  depends_on = [ aws_cloudwatch_log_group.stock-logs ]

}

# 3) CloudWatch 생성 
resource "aws_cloudwatch_log_group" "factory-logs" {
  # 양식 맞춰야함
  name = "/aws/lambda/${var.factory_lambda_name}"
  tags = {"name":"/aws/lambda/${var.factory_lambda_name}"}
}