##############################
# Discover two AZs in region #
##############################
data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}
locals {
  web_subnet_map = {
    az1 = module.vpc.public_subnet_ids[0]
    az2 = module.vpc.public_subnet_ids[1]
  }
}

###############
# Networking #
###############
module "vpc" {
  source               = "./modules/vpc"
  project              = var.project
  vpc_cidr             = var.vpc_cidr
  azs                  = local.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}


####################
# Security Groups #
####################
module "sg" {
  source     = "./modules/sg"
  vpc_id     = module.vpc.vpc_id
  my_ip_cidr = var.my_ip_cidr
  enable_ssh = false
}


########################
# Web EC2 in Public AZs #
########################
module "ec2" {
  source = "./modules/ec2"

  project                   = var.project
  public_subnet_map         = local.web_subnet_map
  web_sg_id                 = module.sg.web_sg_id
  key_name                  = var.key_name
  iam_instance_profile_name = aws_iam_instance_profile.ssm.name
  dd_site                   = var.dd_site
  # Optional:
  dd_logs_enabled = true

}


#############################################
# Secure, RDS-safe password generation #
#############################################
resource "random_password" "rds_master" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}:?,."
}


###################
# RDS in Privates #
###################
module "rds" {
  source = "./modules/rds"


  project            = var.project
  private_subnet_ids = module.vpc.private_subnet_ids
  db_sg_id           = module.sg.db_sg_id


  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage_gb = 20
  multi_az             = var.multi_az_db


  master_username = "admin"
  master_password = random_password.rds_master.result
}

module "alb" {
  source                  = "./modules/alb"
  project                 = var.project
  project_slug            = "city-of-anaheim-cloud-project"
  vpc_id                  = module.vpc.vpc_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  alb_sg_id               = module.sg.alb_sg_id
  target_instance_ids_map = module.ec2.instance_ids_map
  # Optional:
  health_check_path = "/"
  listener_port     = 80
  target_port       = 80
}
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm" {
  name_prefix        = "ssm-role-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "ssm" {
  name_prefix = "ssm-profile-"
  role        = aws_iam_role.ssm.name
}
