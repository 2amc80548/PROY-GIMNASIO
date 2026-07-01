resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "app.internal"
  description = "Namespace privado para service discovery interno"
  vpc         = aws_vpc.main.id
}

# 1. Directorio para NATS
resource "aws_service_discovery_service" "nats" {
  name = "nats"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config { failure_threshold = 1 }
}

# 2. Directorio para Members
resource "aws_service_discovery_service" "members" {
  name = "members"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

# 3. Directorio para Billing
resource "aws_service_discovery_service" "billing" {
  name = "billing"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

# 4. Directorio para Access-Control
resource "aws_service_discovery_service" "access_control" {
  name = "access-control"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}