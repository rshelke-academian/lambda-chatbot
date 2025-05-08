variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket for Lambda deployment package"
  type        = string
}

variable "deployment_package_key" {
  description = "S3 key for the Lambda deployment package"
  type        = string
  default     = "deployment.zip"
} 

