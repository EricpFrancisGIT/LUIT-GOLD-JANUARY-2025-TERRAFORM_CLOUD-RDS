terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "LevelUpWithLeviathan"

    workspaces {
      name = "leveling-up-with-leviathan-main"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.50" # uses the new integration_aws_account resource
    }
  }
}
variable "dd_api_key" {
  description = "Datadog API key for agent install"
  type        = string
  sensitive   = true
}

variable "dd_site" {
  description = "Datadog site (e.g. datadoghq.com, datadoghq.eu)"
  type        = string
  default     = "datadoghq.com"
}
