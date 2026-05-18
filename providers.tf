variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into"
  default     = "us-east-1"
}


provider "aws" {
  region = var.aws_region
}

