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
   filename         = "todo-backend/build/libs/TodoApp-0.0.2-shadow.jar"
   function_name    = "TodoAppHermanStornesTF"
   role             = aws_iam_role.some_role.arn
   handler          = "org.springframework.cloud.function.adapter.aws.FunctionInvoker::handleRequest"
   runtime          = "java21"
   source_code_hash = filebase64sha256("todo-backend/build/libs/TodoApp-0.0.2-shadow.jar")
   timeout          = 900

   environment {
     variables = {
       SPRING_CLOUD_FUNCTION_DEFINITION = "streamLambdaHandler"
     }
   }
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

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "todos"

  depends_on = [aws_api_gateway_integration.integration]
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

output "base_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}
