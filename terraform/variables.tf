variable "aws_region" {
  description = "AWS region used by AWS Academy sandbox"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "student-feedback"
}

variable "my_ip_cidr" {
  description = "Your public IP address for SSH access. This will be restricted later."
  type        = string
  default     = "0.0.0.0/0"
}

variable "db_username" {
  description = "RDS SQL Server master username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "RDS SQL Server master password"
  type        = string
  sensitive   = true
}
