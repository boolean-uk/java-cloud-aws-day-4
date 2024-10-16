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
