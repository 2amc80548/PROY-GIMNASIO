resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}/db-password"
  description             = "Password maestro de MySQL (RDS) para el gimnasio."
  recovery_window_in_days = 0  # borrado inmediato al hacer destroy (útil en un lab)
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}