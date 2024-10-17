provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_role" {
  name = "wahlandtleo@gmail.com"
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

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-west-1:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/*"
}

resource "aws_lambda_function" "backend" {
  filename         = "backend.zip"
  function_name    = "leoPetstoreTerraform"
  role             = aws_iam_role.lambda_role.arn
  handler          = "com.amazonaws.serverless.sample.springboot3.StreamLambdaHandler::handleRequest"
  runtime          = "java21"
  source_code_hash = filebase64sha256("backend.zip")
  memory_size = 512  # Increase memory if needed
  timeout     = 120   # Increase timeout if necessary
}

resource "aws_api_gateway_rest_api" "api" {
  name = "leosPetstoreAPI"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "pets"
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
  depends_on = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

output "api_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

