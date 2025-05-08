terraform {
  backend "s3" {
    bucket = "lambda-deployment21"           # Your existing bucket
    key    = "terraform/chatbot-lambda.tfstate"  # Path inside bucket
    region = "us-east-1"
  }
}
