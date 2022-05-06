module "dynamodb" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table?ref=v1.2.2"

  name               = "scheduled_tasks"
  hash_key           = "OwnerId"
  range_key          = "TaskId"
  ttl_enabled        = true
  ttl_attribute_name = "TTL"
  attributes = [
    {
      name = "OwnerId"
      type = "S"
    },
    {
      name = "TaskId"
      type = "S"
    },
    {
      name = "TTL"
      type = "S"
    }
  ]
}
