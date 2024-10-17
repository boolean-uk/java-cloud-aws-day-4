## Solution



https://7lqjtjlgnb.execute-api.eu-west-1.amazonaws.com/prod/pets

Done with pets using Terraform.

The main.tf is the file i used for my lambda function.


# JAVA Cloud AWS - Day Four

## Learning Objectives
   - Automate AWS Lambda deployments using Terraform.
   - Explore using Terraform to deploy and manage other parts of the AWS stack
   - (Optional) Split backend functionalities into separate Lambda functions, triggered via HTTP calls.


## Use Terraform to Automate Lambda Deployment
## Prerequisites:
   -[] Ensure that Terraform CLI is installed and AWS CLI is configured.
### Steps
1. Write Terraform Configuration:
    - In your project folder, create a file named main.tf with the following content:
    ```bash
      provider "aws" {
         region = "eu-north-1"
      }

      resource "aws_iam_role" "lambda_role" {
         name = "lambda_role"
         assume_role_policy = jsonencode({
            Version = "2012-10-17",
            Statement = [{
               Action = "sts:AssumeRole",
               Effect = "Allow",
               Principal = {
               Service = "lambda.amazonaws.com"
               }
            }]
         })
      }

      resource "aws_lambda_function" "backend" {
         filename         = "backend.zip"
         function_name    = "MyBackendFunction"
         role             = aws_iam_role.lambda_role.arn
         handler          = "Backend::Backend.Function::FunctionHandler"
         runtime          = "java" -- JAVAENVIRONMENT
         source_code_hash = filebase64sha256("backend.zip")
      }

      resource "aws_api_gateway_rest_api" "api" {
         name = "MyBackendAPI"
      }

      resource "aws_api_gateway_resource" "resource" {
         rest_api_id = aws_api_gateway_rest_api.api.id
         parent_id   = aws_api_gateway_rest_api.api.root_resource_id
         path_part   = "register"
      }

      resource "aws_api_gateway_method" "method" {
         rest_api_id   = aws_api_gateway_rest_api.api.id
         resource_id   = aws_api_gateway_resource.resource.id
         http_method   = "GET"
         authorization = "NONE"
      }

      resource "aws_api_gateway_integration" "integration" {
         rest_api_id = aws_api_gateway_rest_api.api.id
         resource_id = aws_api_gateway_resource.resource.id
         http_method = aws_api_gateway_method.method.http_method
         type        = "AWS_PROXY"
         integration_http_method = "POST"
         uri         = aws_lambda_function.backend.invoke_arn
      }
   ```

2. Package Your Lambda Code:
   - Publish your Lambda function using the following commands:
   ```bash
   dotnet publish -c Release -o out --JAVA COMMAND TO PUBLISH
   cd out
   zip -r backend.zip .

   ```

3. Run Terraform:
   - Initialize Terraform:
   ```bash
   terraform init
   ```
   - Apply the configuration:
   ```bash
   terraform apply
   ```
4. Verify Lambda and API Gateway Deployment:
   - Check the API Gateway endpoint URL in AWS and ensure it is connected to the Lambda function by visiting `https://your-api-id.execute-api.region.amazonaws.com/register`.

## (Optional) Split Functionalities into Multiple Lambda Functions
### Steps

1. Create Additional Lambda Functions:
   - Create separate Lambda functions to handle different tasks. For example, create one function for user registration and another for order processing.

2. Update API Gateway:
   - In API Gateway, add new routes like `/register` and `/order`, linking each route to its respective Lambda function.

3. Test the API:
   - Verify that different routes trigger different Lambda functions. For instance:
   - `/register` calls the user registration function.
   - `/order` calls the order processing function.

## Explore further

Once you have successfully used Terraform to deploy an application to AWS Lambda, explore the capabilitities of Terraform more fully.
  - What other AWS platforms can you deploy using Terraform?
  - What limitations and problems might you experience?
  - Are there parts fo the stack which cannot be managed with AWS?

## Deliverables

Make sure you don't accidentally expose any of your secret information when doing the following.

### Core

A working install of the AWS Lambda functions deployed using Terraform (screenshot your successes and post them here with a commentary) and link to them.

### Extension

A working install of something else successfully deployed using Terraform, again post screenshots of your successes etc as well as link to them.
