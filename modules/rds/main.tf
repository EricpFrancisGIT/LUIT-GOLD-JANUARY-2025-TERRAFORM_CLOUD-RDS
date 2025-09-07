locals {
  # Lowercase is sufficient for RDS DB subnet group name rules
  project_sanitized = lower(var.project)
}
resource "aws_db_subnet_group" "this" {
  name       = "${local.project_sanitized}-db-subnets"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "${var.project}-db-subnets", Project = var.project, Tier = "db" }
}

resource "aws_db_instance" "this" {

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage_gb

  username = var.master_username
  password = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]

  publicly_accessible        = false
  skip_final_snapshot        = true
  deletion_protection        = false
  apply_immediately          = true
  auto_minor_version_upgrade = true
  multi_az                   = var.multi_az

  storage_type = "gp3"
  port         = 3306
  # db_name = "appdb"

  tags = {
    Name    = "${var.project}-mysql"
    Project = var.project
    Tier    = "db"
  }
}