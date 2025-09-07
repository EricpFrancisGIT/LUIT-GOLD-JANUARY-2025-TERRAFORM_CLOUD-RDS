variable "project" { type = string }
variable "project_slug" {
  type    = string
  default = null
}
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "alb_sg_id" { type = string }
variable "target_instance_ids_map" { type = map(string) }
variable "health_check_path" {
  type    = string
  default = "/"
}
variable "listener_port" {
  type    = number
  default = 80
}
variable "target_port" {
  type    = number
  default = 80
}

variable "dd_api_key" {
  type      = string
  sensitive = true
  default   = null
}
variable "dd_site" {
  type    = string
  default = "datadoghq.com"
}
variable "dd_logs_enabled" {
  type    = bool
  default = true
}
