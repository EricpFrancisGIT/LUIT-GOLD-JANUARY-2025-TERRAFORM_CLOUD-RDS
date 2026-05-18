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
  }
}