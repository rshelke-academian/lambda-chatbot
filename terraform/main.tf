terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Random string for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Generate bucket name
locals {
  bucket_name = "chatbot-lambda-deployment-${random_string.suffix.result}"
}

# Output bucket name to a file
resource "local_file" "bucket_name" {
  content  = local.bucket_name
  filename = "${path.module}/bucket_name.txt"
}

# S3 bucket for Lambda deployment
resource "aws_s3_bucket" "lambda_deployment" {
  bucket = "chatbot-lambda-deployment-rl1jdeb1"
}

resource "aws_s3_bucket_versioning" "lambda_deployment" {
  bucket = aws_s3_bucket.lambda_deployment.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lambda function using existing LambdaExecutionRole
resource "aws_lambda_function" "chatbot" {
  s3_bucket     = aws_s3_bucket.lambda_deployment.id
  s3_key        = "lambda_function.zip"
  function_name = "${var.project_name}-chatbot"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = {
      AWS_REGION = var.aws_region
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "chatbot_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }
}

resource "aws_apigatewayv2_stage" "chatbot_stage" {
  api_id = aws_apigatewayv2_api.chatbot_api.id
  name   = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.chatbot_api.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.chatbot.invoke_arn
}

resource "aws_apigatewayv2_route" "chatbot_route" {
  api_id    = aws_apigatewayv2_api.chatbot_api.id
  route_key = "POST /chat"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.chatbot_api.execution_arn}/*/*"
}

# IAM role for Lambda
data "aws_iam_role" "lambda_role" {
  name = "chatbot-lambda-role"
}

# IAM policies for Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = data.aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "bedrock_policy" {
  name = "bedrock_policy"
  role = data.aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:*"
        ]
        Resource = "*"
      }
    ]
  })
} 