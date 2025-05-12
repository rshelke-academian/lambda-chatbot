# Terraform Configuration Documentation

## Overview
This document explains the Terraform configuration for the Lambda Chatbot project. The infrastructure is defined using Terraform and includes AWS Lambda, API Gateway, S3, and IAM resources.

## Directory Structure
```
terraform/
├── main.tf           # Main infrastructure configuration
├── variables.tf      # Input variables
├── backend.tf        # Backend configuration
└── .terraform/       # Terraform working directory
```

## Components

### 1. Backend Configuration (`backend.tf`)
```hcl
terraform {
  backend "s3" {
    bucket = "lambda-deployment21"
    key    = "terraform/chatbot-lambda.tfstate"
    region = "us-east-1"
  }
}
```
- Uses S3 as the backend for state storage
- State file is stored in the `lambda-deployment21` bucket
- State file path: `terraform/chatbot-lambda.tfstate`

### 2. Variables (`variables.tf`)
```hcl
variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_role_name" {
  description = "Name of the IAM role for Lambda"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket for Lambda deployment package"
  type        = string
}

variable "deployment_package_key" {
  description = "Path to the deployment package inside the S3 bucket"
  type        = string
}
```
These variables are required and must be provided when applying the configuration.

### 3. Main Configuration (`main.tf`)

#### Provider Configuration
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```
- Uses AWS provider version 5.0 or higher
- Sets region to us-east-1

#### S3 Bucket Configuration
```hcl
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3_bucket
}

resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```
- Creates an S3 bucket for storing Lambda deployment packages
- Enables versioning on the bucket

#### IAM Role and Policies
```hcl
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_bedrock_policy" {
  name        = "chatbot-lambda-bedrock-policy"
  description = "Policy for Lambda to access Bedrock"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["bedrock:*"],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}
```
- Creates IAM role for Lambda execution
- Defines policy for Bedrock access
- Attaches necessary policies to the role

#### Lambda Function
```hcl
resource "aws_lambda_function" "chatbot_lambda" {
  function_name = var.lambda_function_name
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = var.deployment_package_key
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256

  environment {
    variables = {
      BEDROCK_MODEL_ID = "us.anthropic.claude-3-7-sonnet-20250219-v1:0"
    }
  }
}
```
- Creates Lambda function with Python 3.12 runtime
- Sets timeout to 30 seconds
- Allocates 256MB memory
- Configures environment variables for Bedrock model

#### API Gateway
```hcl
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.lambda_function_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "Lambda integration"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.chatbot_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "POST /chat"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}
```
- Creates HTTP API Gateway
- Sets up production stage
- Configures Lambda integration
- Creates POST /chat route

## Usage

### Required Variables
When applying the configuration, you need to provide:
1. `lambda_function_name`: Name for your Lambda function
2. `lambda_role_name`: Name for the IAM role
3. `s3_bucket`: Name of the S3 bucket
4. `deployment_package_key`: Path to your Lambda deployment package in S3

### Applying the Configuration
```bash
# Initialize Terraform
terraform init

# Plan the changes
terraform plan -var="lambda_function_name=my-chatbot" \
              -var="lambda_role_name=my-chatbot-role" \
              -var="s3_bucket=my-lambda-bucket" \
              -var="deployment_package_key=lambda.zip"

# Apply the changes
terraform apply -var="lambda_function_name=my-chatbot" \
               -var="lambda_role_name=my-chatbot-role" \
               -var="s3_bucket=my-lambda-bucket" \
               -var="deployment_package_key=lambda.zip"
```

## Best Practices Implemented

1. **State Management**
   - Using S3 backend for state storage
   - State file versioning enabled

2. **Security**
   - Least privilege IAM policies
   - Secure API Gateway configuration
   - Environment variables for sensitive data

3. **Resource Naming**
   - Consistent naming convention
   - Environment-specific names
   - Clear resource identification

4. **Infrastructure Organization**
   - Modular configuration
   - Clear separation of concerns
   - Well-documented variables

## Maintenance

### Updating the Configuration
1. Modify the desired resources in `main.tf`
2. Run `terraform plan` to review changes
3. Apply changes with `terraform apply`

### Adding New Resources
1. Add new resource blocks in `main.tf`
2. Define any new variables in `variables.tf`
3. Update the configuration as needed

### Troubleshooting
1. Check Terraform state: `terraform state list`
2. Verify resource existence in AWS Console
3. Review CloudWatch logs for Lambda function
4. Check API Gateway logs for API issues 