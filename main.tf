provider "aws" {
   region = "eu-west-1"
}

resource "aws_iam_role" "some_role" {
   name = "some_role"
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
   filename         = "TodoApp-0.0.2.jar"
   function_name    = "TodoAppHermanStornesTF"
   role             = aws_iam_role.some_role.arn
   handler          = "com.booleanuk.StreamLambdaHandler::handleRequest"
   runtime          = "java21"
   source_code_hash = filebase64sha256("TodoApp-0.0.2.jar")
}

resource "aws_api_gateway_rest_api" "api" {
   name = "TodoAppHermanStornesTF"
}

resource "aws_api_gateway_resource" "resource" {
   rest_api_id = aws_api_gateway_rest_api.api.id
   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
   path_part   = "todos"
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
