variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. local, aws)"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "project_name_prefix" {
  type        = string
  description = "Short prefix used for AWS resource names (max 20 chars)"
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
