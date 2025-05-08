# AWS Lambda Chatbot with Amazon Bedrock

This project implements a serverless AI chatbot using AWS Lambda and Amazon Bedrock, with CI/CD automation through GitHub Actions.

## Prerequisites

- Python 3.12 (AWS Lambda compatible version)
- AWS CLI configured with appropriate credentials
- Terraform installed
- GitHub account with repository access

## Project Structure

```
lambda_chatbot/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── src/
│   ├── lambda_function.py
│   └── requirements.txt
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```

## Local Development Setup

1. Create a virtual environment with Python 3.12:
   ```bash
   python3.12 -m venv venv
   source venv/bin/activate  # On Unix/MacOS
   # OR
   .\venv\Scripts\activate  # On Windows
   ```

2. Install dependencies:
   ```bash
   pip install -r src/requirements.txt
   ```

3. Set up AWS credentials:
   ```bash
   aws configure
   ```

## Deployment

The project uses GitHub Actions for CI/CD. The workflow will:
1. Create a deployment package
2. Upload to S3
3. Deploy using Terraform

### Required GitHub Secrets
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

## Infrastructure

The Terraform configuration creates:
- S3 bucket for Lambda code
- Lambda function
- API Gateway
- IAM roles and permissions

## Testing

The Lambda function can be tested through:
- API Gateway endpoint
- AWS Console
- AWS CLI

## License

MIT License 