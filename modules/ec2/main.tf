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

  # Render this only if dd_api_key is set
  datadog_userdata = var.dd_api_key == null ? "" : <<-EODD
    # Datadog Agent install (Linux)
    DD_API_KEY=${var.dd_api_key} DD_SITE=${var.dd_site} bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"
    if [ "${var.dd_logs_enabled}" = "true" ]; then
      echo "logs_enabled: true" >> /etc/datadoghq-agent/datadog.yaml || true
      systemctl restart datadog-agent || true
    fi
  EODD

  # Final user-data = NGINX + (optional) Datadog
  user_data = "${chomp(local.nginx_userdata)}\n${chomp(local.datadog_userdata)}"
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

  user_data = local.user_data

  tags = {
    Name    = "${var.project}-web-${each.key}"
    Project = var.project
    Tier    = "web"
  }
}
