resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Permite HTTP entrante desde internet hacia el ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP desde internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-alb-sg" }
}

resource "aws_security_group" "members" {
  name        = "${var.project_name}-members-sg"
  description = "Permite trafico solo desde el ALB hacia members:3000"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP desde ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-members-sg" }
}

resource "aws_security_group" "billing" {
  name        = "${var.project_name}-billing-sg"
  description = "billing no acepta HTTP (microservicio NATS puro)"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-billing-sg" }
}

resource "aws_security_group" "access_control" {
  name        = "${var.project_name}-access-control-sg"
  description = "access-control no acepta HTTP (microservicio NATS puro)"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-access-control-sg" }
}

# --- REGLAS AISLADAS PARA NATS ---
resource "aws_security_group" "nats" {
  name        = "${var.project_name}-nats-sg"
  description = "Broker NATS: ingreso desde los 3 microservicios"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-nats-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "nats_from_members" {
  security_group_id            = aws_security_group.nats.id
  referenced_security_group_id = aws_security_group.members.id
  ip_protocol                  = "tcp"
  from_port                    = 4222
  to_port                      = 4222
}

resource "aws_vpc_security_group_ingress_rule" "nats_from_billing" {
  security_group_id            = aws_security_group.nats.id
  referenced_security_group_id = aws_security_group.billing.id
  ip_protocol                  = "tcp"
  from_port                    = 4222
  to_port                      = 4222
}

resource "aws_vpc_security_group_ingress_rule" "nats_from_access_control" {
  security_group_id            = aws_security_group.nats.id
  referenced_security_group_id = aws_security_group.access_control.id
  ip_protocol                  = "tcp"
  from_port                    = 4222
  to_port                      = 4222
}

# --- REGLAS AISLADAS PARA MYSQL (RDS) ---
resource "aws_security_group" "mysql" {
  name        = "${var.project_name}-mysql-sg"
  description = "RDS MySQL: ingreso solo desde members"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.project_name}-mysql-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "mysql_from_members" {
  security_group_id            = aws_security_group.mysql.id
  referenced_security_group_id = aws_security_group.members.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}