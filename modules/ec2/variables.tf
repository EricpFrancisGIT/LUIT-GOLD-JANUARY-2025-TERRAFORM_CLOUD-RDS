variable "project" { type = string }
variable "public_subnet_map" { type = map(string) } # e.g., { az1 = "subnet-...", az2 = "subnet-..." }
variable "web_sg_id" { type = string }
variable "key_name" {
  type    = string
  default = null
}
variable "iam_instance_profile_name" {
  type    = string
  default = null
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
