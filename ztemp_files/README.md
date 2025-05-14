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
- `AWS_ROLE_ARN`: ARN of the IAM role for GitHub Actions OIDC authentication
- `S3_BUCKET`: Name of the S3 bucket for Lambda deployments

### Setting up OIDC Authentication
1. Create an IAM role in AWS with the following trust policy:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<YOUR-AWS-ACCOUNT-ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:sub": "repo:<YOUR-GITHUB-ORG>/<YOUR-REPO>:ref:refs/heads/main"
                }
            }
        }
    ]
}
```

2. Attach the necessary permissions to the role:
   - S3 access for deployment
   - Lambda management
   - API Gateway management
   - Bedrock access

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