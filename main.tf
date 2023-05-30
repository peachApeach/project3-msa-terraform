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

  policy = <<POLICY
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



