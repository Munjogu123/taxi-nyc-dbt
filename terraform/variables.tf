variable "aws_region" {
  description = "The AWS region to launch our EC2 instance"
  type        = string
  default     = "eu-north-1"
}

variable "aws_availability_zone" {
  description = "AWS Availability zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "bucket_name" {
  description = "Name of our S3 bucket"
  type        = string
  default     = "nyc-taxi-dataset4569"
}

variable "redshift_admin_username" {
  description = "Admin username for Redshift Serverless"
  type        = string
  default     = "adminuser"
}

variable "redshift_admin_password" {
  description = "Admin password for Redshift Serverless"
  type        = string
  sensitive   = true
}
