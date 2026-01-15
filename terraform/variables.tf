variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "db_name" {
  type        = string
  description = "PostgreSQL database name"
}

variable "db_username" {
  type        = string
  description = "PostgreSQL username"
}

variable "db_password" {
  type        = string
  description = "PostgreSQL password"
  sensitive   = true
}
