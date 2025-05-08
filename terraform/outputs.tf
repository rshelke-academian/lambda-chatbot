output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.chatbot.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.chatbot.arn
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "${aws_apigatewayv2_api.chatbot_api.api_endpoint}/chat"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Lambda deployment"
  value       = aws_s3_bucket.lambda_deployment.bucket
} 