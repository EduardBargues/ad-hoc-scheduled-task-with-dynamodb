locals {
  lambdas = {
    schedule_task = {
      function_name          = "schedule-task"
      local_existing_package = "schedule-task.zip"
      policy_statements = {
        dynamodb = {
          effect    = "Allow",
          actions   = ["dynamodb:*"],
          resources = [module.dynamodb.dynamodb_table_arn, module.dynamodb.dynamodb_table_stream_arn]
        }
      }
    }
    on_task_executed = {
      function_name          = "execute-task"
      local_existing_package = "execute-task.zip"
      policy_statements = {
        dynamodb = {
          effect    = "Allow",
          actions   = ["dynamodb:*"],
          resources = [module.dynamodb.dynamodb_table_arn, module.dynamodb.dynamodb_table_stream_arn]
        }
      }
    }
  }
}

module "lambda_function" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda?ref=v3.2.0"

  for_each = local.lambdas

  function_name            = each.value.function_name
  handler                  = "main.handler"
  runtime                  = "nodejs14.x"
  create_package           = false
  local_existing_package   = each.value.local_existing_package
  attach_policy_statements = each.value.policy_statements != {}
  policy_statements        = each.value.policy_statements
  environment_variables = {
    DYNAMODB_TABLE_NAME = local.dynamodb_table_name
  }
}
