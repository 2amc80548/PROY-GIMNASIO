resource "aws_cloudwatch_log_group" "nats" {
  name              = "/ecs/${var.project_name}/nats"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "members" {
  name              = "/ecs/${var.project_name}/members"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "billing" {
  name              = "/ecs/${var.project_name}/billing"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "access_control" {
  name              = "/ecs/${var.project_name}/access-control"
  retention_in_days = 7
}