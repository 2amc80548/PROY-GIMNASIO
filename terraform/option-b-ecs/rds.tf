resource "aws_db_subnet_group" "mysql" {
  name       = "${var.project_name}-mysql-subnets"
  subnet_ids = aws_subnet.public[*].id
}

resource "aws_db_instance" "mysql" {
  identifier             = "${var.project_name}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp2"
  multi_az               = var.db_multi_az
  
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  
  skip_final_snapshot    = true
  publicly_accessible    = false
}