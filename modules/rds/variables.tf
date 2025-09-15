variable "project" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_sg_id" { type = string }


variable "engine" {
  type    = string
  default = "mysql"
}
variable "engine_version" {
  type    = string
  default = "8.0"
}
variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "allocated_storage_gb" {
  type    = number
  default = 20
}
variable "multi_az" {
  type    = bool
  default = false
}

variable "master_username" {
  type    = string
  default = "admin"
}
variable "master_password" {
  type      = string
  sensitive = true
}