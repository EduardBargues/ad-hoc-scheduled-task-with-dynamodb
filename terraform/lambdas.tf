locals {
  lambdas = {
    schedule_task    = "../src/functions/schedule-task/schedule-task.zip",
    on_task_executed = "../src/functions/on-task-executed/on-task-executed.zip"
  }
}

module "lambda_function" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda?ref=v3.2.0"

  for_each = local.lambdas

  function_name            = each.key
  handler                  = "main.handler"
  runtime                  = "nodejs14.x"
  create_package           = false
  local_existing_package   = each.value
  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow",
      actions   = ["dynamodb:*"],
      resources = [module.dynamodb.dynamodb_table_arn, module.dynamodb.dynamodb_table_stream_arn]
    }
  }
  environment_variables = {
    DYNAMODB_TABLE_NAME = local.dynamodb_table_name
  }
}
