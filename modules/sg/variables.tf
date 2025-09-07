variable "vpc_id" { type = string }
variable "my_ip_cidr" { type = string }
variable "enable_ssh" {
  type    = bool
  default = false
}