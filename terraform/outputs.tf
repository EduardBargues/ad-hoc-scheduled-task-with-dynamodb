output "schedule_task_url" {
  value = "${aws_api_gateway_deployment.api.invoke_url}${local.stage}/${local.path}"
}
