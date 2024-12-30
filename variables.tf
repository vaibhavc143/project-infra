variable "vpc_id" {
  description = "The VPC ID where resources will be deployed"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for EC2 instance"
  type        = string
}

variable "rds_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}
