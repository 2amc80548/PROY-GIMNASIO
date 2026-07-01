variable "aws_region" {
  description = "Región de AWS donde se desplegará todo."
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  description = "AWS access key."
  type        = string
  sensitive   = true
  default     = null
}

variable "secret_key" {
  description = "AWS secret key."
  type        = string
  sensitive   = true
  default     = null
}

variable "project_name" {
  description = "Prefijo para nombrar todos los recursos."
  type        = string
  default     = "gestion-gimnasio"
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs de las subnets públicas."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  description = "Availability Zones a usar."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# --- VARIABLES DE LOS MICROSERVICIOS DEL GIMNASIO ---

variable "members_desired_count" {
  description = "Número de tareas para members."
  type        = number
  default     = 1
}

variable "billing_desired_count" {
  description = "Número de tareas para billing."
  type        = number
  default     = 1
}

variable "access_control_desired_count" {
  description = "Número de tareas para access-control."
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "CPU por tarea Fargate."
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memoria por tarea Fargate en MB."
  type        = string
  default     = "512"
}

variable "image_tag" {
  description = "Tag de las imágenes en ECR."
  type        = string
  default     = "latest"
}

# --- VARIABLES DE MYSQL (RDS) ---

variable "db_instance_class" {
  description = "Tipo de nodo RDS para MySQL."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nombre de la base de datos MySQL."
  type        = string
  default     = "gimnasio_db"
}

variable "db_username" {
  description = "Usuario maestro de MySQL."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Contraseña maestra de MySQL (se pasa por tfvars)."
  type        = string
  sensitive   = true
}