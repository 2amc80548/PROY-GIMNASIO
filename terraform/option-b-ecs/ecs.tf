resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  ecr_registry         = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  
  members_image        = "${aws_ecr_repository.members.repository_url}:${var.image_tag}"
  billing_image        = "${aws_ecr_repository.billing.repository_url}:${var.image_tag}"
  access_control_image = "${aws_ecr_repository.access_control.repository_url}:${var.image_tag}"

  nats_dns_url         = "nats://nats.${aws_service_discovery_private_dns_namespace.main.name}:4222"
}

# ----------------- TASK DEFINITIONS -----------------

resource "aws_ecs_task_definition" "nats" {
  family                   = "${var.project_name}-nats"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name      = "nats"
    image     = "nats:2.10-alpine"
    essential = true
    command   = ["-js", "-m", "8222"]
    portMappings = [
      { containerPort = 4222, protocol = "tcp" },
      { containerPort = 8222, protocol = "tcp" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.nats.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "nats"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "members" {
  family                   = "${var.project_name}-members"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name      = "members"
    image     = local.members_image
    essential = true
    portMappings = [
      { containerPort = 3000, protocol = "tcp" }
    ]
   environment = [
      { name = "NATS_URL", value = local.nats_dns_url },
      { name = "DB_HOST", value = aws_db_instance.mysql.address },
      { name = "DB_USERNAME", value = var.db_username },
      { name = "DB_NAME", value = var.db_name },
      { name = "MEMBERS_HTTP_PORT", value = "3000" }
    ]
    secrets = [
      { name = "DB_PASSWORD", valueFrom = aws_secretsmanager_secret.db_password.arn }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.members.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "members"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "billing" {
  family                   = "${var.project_name}-billing"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name      = "billing"
    image     = local.billing_image
    essential = true
    environment = [
      { name = "NATS_URL", value = local.nats_dns_url }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.billing.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "billing"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "access_control" {
  family                   = "${var.project_name}-access-control"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name      = "access-control"
    image     = local.access_control_image
    essential = true
    environment = [
      { name = "NATS_URL", value = local.nats_dns_url }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.access_control.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "access-control"
      }
    }
  }])
}

# ----------------- SERVICES -----------------

resource "aws_ecs_service" "nats" {
  name            = "nats"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nats.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.nats.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.nats.arn
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

}


resource "aws_ecs_service" "members" {
  name            = "members"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.members.arn
  desired_count   = var.members_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.members.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.members.arn
    container_name   = "members"
    container_port   = 3000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.members.arn
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "billing" {
  name            = "billing"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.billing.arn
  desired_count   = var.billing_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.billing.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.billing.arn
  }
}

resource "aws_ecs_service" "access_control" {
  name            = "access-control"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.access_control.arn
  desired_count   = var.access_control_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.access_control.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.access_control.arn
  }
}