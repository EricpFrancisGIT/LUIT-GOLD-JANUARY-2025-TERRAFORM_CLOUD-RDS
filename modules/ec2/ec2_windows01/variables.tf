variable "project" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.large"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "iam_instance_profile" {
  type    = string
  default = null
}

variable "key_name" {
  type    = string
  default = null
}

variable "associate_public_ip_address" {
  type    = bool
  default = true
}

variable "user_data" {
  type    = string
  default = null
}

variable "root_volume_size" {
  type    = number
  default = 50
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "role" {
  type    = string
  default = "iis"
}