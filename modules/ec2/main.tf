# Latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  owners      = ["137112412989"] # Amazon
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  nginx_userdata = <<-EONGX
    #!/bin/bash
    dnf -y update
    dnf -y install nginx
    systemctl enable nginx
    echo "<h1>Greetings from ${var.project} — $(hostname)</h1>" > /usr/share/nginx/html/index.html
    systemctl start nginx
  EONGX
}
# One instance per public subnet (stable keys from a map)
resource "aws_instance" "city_of_anaheim_instance" {
  for_each = var.public_subnet_map

  ami                         = data.aws_ami.al2023.id
  instance_type               = "t2.micro"
  subnet_id                   = each.value
  vpc_security_group_ids      = [var.web_sg_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile_name

  user_data = local.nginx_userdata

  tags = {
    Name    = "${var.project}-web-${each.key}"
    Project = var.project
    Tier    = "web"
  }
}
