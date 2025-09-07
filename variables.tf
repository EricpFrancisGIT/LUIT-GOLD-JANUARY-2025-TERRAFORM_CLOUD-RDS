variable "project" {
  description = "Project name prefix for tagging"
  type        = string
  default     = "City Of Anaheim Cloud Project"
}


variable "my_ip_cidr" {
  description = "Your workstation public IP in CIDR (e.g., 203.0.113.55/32) for SSH access"
  type        = string
  default     = "0.0.0.0/0" # Update to your IP for better security
}


variable "key_name" {
  description = "Existing EC2 key pair name (optional for SSH)"
  type        = string
  default     = null
}


# Network CIDRs (customize as needed)
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}


variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}


variable "multi_az_db" {
  description = "Enable multi-AZ for RDS (costs more)"
  type        = bool
  default     = true
}

