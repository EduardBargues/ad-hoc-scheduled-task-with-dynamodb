locals {
  dynamodb_table_name = "scheduled_tasks"
}

module "dynamodb" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v1.2.2"

  name      = local.dynamodb_table_name
  hash_key  = "OwnerId"
  range_key = "TaskId"
  attributes = [
    {
      name = "OwnerId"
      type = "S"
    },
    {
      name = "TaskId"
      type = "S"
    }
  ]

  ttl_enabled        = true
  ttl_attribute_name = "TTL"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = module.dynamodb.dynamodb_table_stream_arn
  function_name     = module.lambda_function["on_task_executed"].lambda_function_arn
  starting_position = "LATEST"
}
