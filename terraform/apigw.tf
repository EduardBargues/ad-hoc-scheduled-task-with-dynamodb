data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  path        = "schedule-task"
  http_method = "POST"
  account_id  = data.aws_caller_identity.current.account_id
  aws_region  = data.aws_region.current.name
  api_id      = aws_api_gateway_rest_api.api.id
  stage       = "dev"
}

resource "aws_api_gateway_rest_api" "api" {
  name = "scheduled_tasks"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = local.api_id
  triggers = {
    redeployment = timestamp()
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_integration.api,
  ]
}

resource "aws_api_gateway_stage" "api" {
  stage_name    = local.stage
  rest_api_id   = local.api_id
  deployment_id = aws_api_gateway_deployment.api.id
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = local.api_id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = local.path

  lifecycle {
    create_before_destroy = false
  }
}
resource "aws_api_gateway_method" "api" {
  rest_api_id   = local.api_id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = local.http_method
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "api" {
  rest_api_id             = local.api_id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.api.http_method
  integration_http_method = local.http_method
  type                    = "AWS_PROXY"
  uri                     = module.lambda_function["schedule_task"].lambda_function_invoke_arn
}

resource "aws_lambda_permission" "api" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function["schedule_task"].lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.aws_region}:${local.account_id}:${local.api_id}/*/${local.http_method}${aws_api_gateway_resource.api.path}"
}
