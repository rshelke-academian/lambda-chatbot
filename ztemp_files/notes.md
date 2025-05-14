# Lambda Chatbot Project Setup Guide

## Prerequisites and Installation Guide

### 1. Git
Git is required for version control and collaboration.

**Installation:**
- **Windows:**
  - Download from: https://git-scm.com/download/win
  - Run the installer and follow the installation wizard
  - Verify installation: `git --version` windows cmd


### 2. AWS CLI
AWS CLI is required for AWS service interaction and deployment.

**Installation:**
- **Windows:**
  - Download the MSI installer from: https://awscli.amazonaws.com/AWSCLIV2.msi
  - Run the installer
  - Verify installation: `aws --version` on windows cmd 


**Configuration:**
```bash
aws configure 
# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)
confirm your configuration using below command 

```

### 3. Terraform
Terraform is used for infrastructure as code and deployment.

**Installation:**
- **Windows:**
  - Download from: https://developer.hashicorp.com/terraform/downloads
  - Extract the zip file
  - Add the path to system environment variables
  - Verify installation: `terraform --version`

- **macOS:**
  - Using Homebrew: `brew install terraform`
  - Verify installation: `terraform --version`

- **Linux:**
  ```bash
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
  sudo apt install terraform
  terraform --version
  ```

### 4. Python 3.12
Python is required for local development and Lambda function code.

**Installation:**
- **Windows:**
  - Download from: https://www.python.org/downloads/
  - Run the installer
  - Check "Add Python to PATH" during installation
  - Verify installation: `python --version`

- **macOS:**
  - Using Homebrew: `brew install python@3.12`
  - Verify installation: `python3 --version`

- **Linux:**
  ```bash
  sudo apt update
  sudo apt install python3.12
  python3 --version
  ```

## Project Setup Steps

1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd lambda-chatbot
   ```

2. **Set Up Python Virtual Environment:**
   ```bash
   # Windows
   python -m venv venv
   .\venv\Scripts\activate

   # macOS/Linux
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Install Dependencies:**
   ```bash
   pip install -r src/requirements.txt
   ```

4. **AWS Configuration:**
   - Ensure AWS CLI is configured with appropriate credentials
   - Required permissions:
     - Lambda management
     - API Gateway management
     - S3 access
     - Bedrock access

5. **GitHub Setup:**
   - Create a GitHub repository
   - Set up required secrets:
     - `AWS_ROLE_ARN`
     - `S3_BUCKET`

6. **Terraform Initialization:**
   ```bash
   cd terraform
   terraform init
   ```

## Important Links

- **AWS Documentation:**
  - [AWS Lambda](https://docs.aws.amazon.com/lambda/)
  - [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/)
  - [AWS CLI](https://docs.aws.amazon.com/cli/)

- **Terraform Documentation:**
  - [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
  - [Terraform CLI](https://developer.hashicorp.com/terraform/cli)

- **Git Documentation:**
  - [Git Documentation](https://git-scm.com/doc)

## Troubleshooting

1. **AWS CLI Issues:**
   - Verify credentials: `aws sts get-caller-identity`
   - Check AWS configuration: `aws configure list`

2. **Terraform Issues:**
   - Initialize Terraform: `terraform init`
   - Validate configuration: `terraform validate`
   - Check state: `terraform state list`

3. **Python Issues:**
   - Verify Python version: `python --version`
   - Check pip installation: `pip --version`
   - Update pip: `python -m pip install --upgrade pip`

## Security Best Practices

1. **AWS Credentials:**
   - Never commit AWS credentials to version control
   - Use IAM roles and policies with least privilege
   - Rotate access keys regularly

2. **Git Security:**
   - Use SSH keys for authentication
   - Enable two-factor authentication
   - Review code before committing

3. **Terraform Security:**
   - Use remote state storage
   - Enable state encryption
   - Use variables for sensitive data

## Additional Resources

- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Terraform Best Practices](https://cloud.google.com/docs/terraform/best-practices-for-terraform)
- [Git Best Practices](https://github.com/git/git-scm.com/blob/main/Maintenance.md)

## Code Structure and Setup

### Project Structure
```
lambda-chatbot/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD workflow
├── src/
│   ├── lambda_function.py     # Main Lambda function code
│   └── requirements.txt       # Python dependencies
├── terraform/
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Terraform variables
│   ├── backend.tf            # Terraform backend configuration
│   └── .terraform/           # Terraform working directory
└── README.md                 # Project documentation
```

### Code Setup Process

1. **Lambda Function Setup (`src/lambda_function.py`):**
   - Create a new Python file for your Lambda function
   - Basic structure:
   ```python
   import json
   import boto3
   
   def lambda_handler(event, context):
       try:
           # Your chatbot logic here
           return {
               'statusCode': 200,
               'body': json.dumps({
                   'message': 'Success'
               })
           }
       except Exception as e:
           return {
               'statusCode': 500,
               'body': json.dumps({
                   'error': str(e)
               })
           }
   ```

2. **Dependencies Setup (`src/requirements.txt`):**
   ```
   boto3>=1.26.0
   botocore>=1.29.0
   # Add other required packages
   ```

3. **Terraform Configuration:**

   a. **Main Configuration (`terraform/main.tf`):**
   ```hcl
   provider "aws" {
     region = var.aws_region
   }
   
   # Lambda function
   resource "aws_lambda_function" "chatbot" {
     filename         = "../src/lambda_function.zip"
     function_name    = var.lambda_function_name
     role            = aws_iam_role.lambda_role.arn
     handler         = "lambda_function.lambda_handler"
     runtime         = "python3.12"
     timeout         = 30
     memory_size     = 256
   }
   
   # API Gateway
   resource "aws_apigatewayv2_api" "chatbot_api" {
     name          = var.api_name
     protocol_type = "HTTP"
   }
   ```

   b. **Variables (`terraform/variables.tf`):**
   ```hcl
   variable "aws_region" {
     description = "AWS region"
     type        = string
     default     = "us-east-1"
   }
   
   variable "lambda_function_name" {
     description = "Name of the Lambda function"
     type        = string
   }
   ```

4. **GitHub Actions Setup (`.github/workflows/deploy.yml`):**
   ```yaml
   name: Deploy Lambda Chatbot
   
   on:
     push:
       branches: [ main ]
   
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v2
         
         - name: Configure AWS credentials
           uses: aws-actions/configure-aws-credentials@v1
           with:
             aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
             aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
             aws-region: us-east-1
   ```

### Development Workflow

1. **Local Development:**
   ```bash
   # Create and activate virtual environment
   python -m venv venv
   source venv/bin/activate  # Linux/MacOS
   # OR
   .\venv\Scripts\activate   # Windows
   
   # Install dependencies
   pip install -r src/requirements.txt
   
   # Test Lambda function locally
   python -c "from lambda_function import lambda_handler; print(lambda_handler({}, {}))"
   ```

2. **Terraform Development:**
   ```bash
   cd terraform
   
   # Initialize Terraform
   terraform init
   
   # Plan changes
   terraform plan
   
   # Apply changes
   terraform apply
   ```

3. **Testing:**
   - Unit tests for Lambda function
   - Integration tests with API Gateway
   - Terraform configuration validation

### Best Practices

1. **Code Organization:**
   - Keep Lambda function code modular
   - Use separate files for different functionalities
   - Implement proper error handling
   - Add logging for debugging

2. **Security:**
   - Use environment variables for sensitive data
   - Implement proper IAM roles and permissions
   - Enable encryption for data at rest and in transit

3. **Performance:**
   - Optimize Lambda function memory and timeout
   - Implement caching where appropriate
   - Use async operations when possible

4. **Monitoring:**
   - Set up CloudWatch alarms
   - Implement proper logging
   - Monitor API Gateway metrics

### Deployment Process

1. **Manual Deployment:**
   ```bash
   # Package Lambda function
   cd src
   zip -r ../lambda_function.zip .
   
   # Deploy with Terraform
   cd ../terraform
   terraform init
   terraform apply
   ```

2. **Automated Deployment:**
   - Push to main branch triggers GitHub Actions
   - Actions package and deploy the function
   - Terraform manages infrastructure changes

### Testing the Deployment

1. **API Testing:**
   ```bash
   # Get API endpoint from Terraform output
   terraform output api_endpoint
   
   # Test API
   curl -X POST https://your-api-endpoint.execute-api.region.amazonaws.com/stage/chat \
     -H "Content-Type: application/json" \
     -d '{"message": "Hello"}'
   ```

2. **Lambda Testing:**
   ```bash
   # Test Lambda function directly
   aws lambda invoke \
     --function-name your-function-name \
     --payload '{"message": "Hello"}' \
     response.json
   ``` 

## Terraform Setup and Best Practices

### Terraform Configuration Structure

```
terraform/
├── main.tf           # Main infrastructure configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── backend.tf        # Backend configuration
├── providers.tf      # Provider configurations
└── locals.tf         # Local values and common configurations
```

### Essential Variables (`variables.tf`)

```hcl
# AWS Region
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Environment
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Lambda Function
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

# API Gateway
variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_stage_name" {
  description = "Stage name for API Gateway"
  type        = string
  default     = "v1"
}

# Tags
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Project     = "lambda-chatbot"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### Main Configuration (`main.tf`)

```hcl
# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# S3 Bucket for Lambda Code
resource "aws_s3_bucket" "lambda_code" {
  bucket = "${var.lambda_function_name}-code-${var.environment}"
  
  tags = var.tags
}

# Lambda Function
resource "aws_lambda_function" "chatbot" {
  filename         = "../src/lambda_function.zip"
  function_name    = var.lambda_function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.12"
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size
  
  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
  
  tags = var.tags
}

# API Gateway
resource "aws_apigatewayv2_api" "chatbot_api" {
  name          = var.api_name
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }
  
  tags = var.tags
}
```

### IAM Roles and Policies

```hcl
# Lambda Execution Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

# Lambda Basic Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom Policy for Bedrock Access
resource "aws_iam_role_policy" "bedrock_access" {
  name = "${var.lambda_function_name}-bedrock-policy-${var.environment}"
  role = aws_iam_role.lambda_role.id
  
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
```

### Backend Configuration (`backend.tf`)

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "lambda-chatbot/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### Outputs (`outputs.tf`)

```hcl
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.chatbot.function_name
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.chatbot_api.api_endpoint
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}
```

### Terraform Best Practices

1. **State Management:**
   - Use remote state storage (S3 + DynamoDB)
   - Enable state encryption
   - Use state locking
   - Implement state file versioning

2. **Security:**
   - Use least privilege IAM policies
   - Enable encryption at rest
   - Use VPC endpoints for AWS services
   - Implement proper tagging strategy

3. **Code Organization:**
   - Use modules for reusable components
   - Separate environments using workspaces
   - Use consistent naming conventions
   - Document all variables and outputs

4. **Resource Management:**
   - Use data sources for existing resources
   - Implement proper resource dependencies
   - Use count/for_each for multiple resources
   - Implement proper resource lifecycle rules

5. **Variables and Outputs:**
   - Use descriptive variable names
   - Provide default values where appropriate
   - Use validation rules for variables
   - Document all variables and outputs

### Common Terraform Commands

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan -var-file="dev.tfvars"

# Apply changes
terraform apply -var-file="dev.tfvars"

# Destroy resources
terraform destroy -var-file="dev.tfvars"

# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new dev

# Switch workspace
terraform workspace select prod
```

### Environment-specific Variables

Create separate `.tfvars` files for different environments:

```hcl
# dev.tfvars
environment        = "dev"
lambda_memory_size = 256
lambda_timeout     = 30

# prod.tfvars
environment        = "prod"
lambda_memory_size = 512
lambda_timeout     = 60
```

### Terraform Modules

Consider creating reusable modules for common components:

```
modules/
├── lambda/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── api_gateway/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── iam/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
``` 