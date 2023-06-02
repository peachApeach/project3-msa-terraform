# resource "aws_lambda_function" "sales-api-lambda" {
#   function_name = "sales-api-lambda-tf"
#   description = "Sales api gateway function - v.tf"

#   runtime = "nodejs14.x"
#   handler = "handler.handler"

#   filename = data.archive_file.lambda_zip.output_path
#   source_code_hash = data.archive_file.lambda_zip.output_base64sha256

#   role = aws_iam_role.salesapilambda_exec

#   depends_on = [ aws_cloudwatch_log_group.salesapi-logs ]

# }