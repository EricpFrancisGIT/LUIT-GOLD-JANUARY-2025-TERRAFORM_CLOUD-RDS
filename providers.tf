variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into"
  default     = "us-east-1"
}


provider "aws" {
  region = var.aws_region
}
provider "datadog" {
  # picks up DATADOG_API_KEY, DATADOG_APP_KEY, DD_SITE from env
}
