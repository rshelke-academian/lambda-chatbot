variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_role_name" {
  description = "Name of the IAM role for Lambda"
  type        = string
}

variable "lambda_policy_name" {
  description = "Name of the IAM policy for Bedrock access"
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
