terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44"
    }
  }
}

provider "aws" {
  region  = "eu-west-2"
}

resource "aws_lambda_function" "function" {
  function_name     = "my-function-name"
  description       = "My fuction description"
  timeout           = 60
  role              = aws_iam_role.function_role.arn
  runtime           = "python3.11"
  memory_size       = 128
  handler           = "lambda_function.lambda_handler"
  filename          = "lambda_function.zip"  # Specify the path to your pre-existing zip file
  source_code_hash  = filebase64sha256("lambda_function.zip")

}

resource "aws_iam_role" "function_role" {
  name                 = "my-lambda-function-role"
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

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.function_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy" "policy" {

  name        = "my-lambda-policy"
  description = "IAM policy for the lambda function"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "*"
      }
    ]
  })
}