resource "aws_vpc" "template" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project}-vpc" }
}

resource "aws_internet_gateway" "template" {
  vpc_id = aws_vpc.template.id
  tags   = { Name = "${var.project}-igw" }
}

# Public subnets (indexed "0","1")
resource "aws_subnet" "template_public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : tostring(idx) => cidr }

  vpc_id                  = aws_vpc.template.id
  cidr_block              = each.value
  availability_zone       = var.azs[tonumber(each.key)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-${each.key}"
    Tier = "public"
  }
}

# Private subnets (indexed "0","1")
resource "aws_subnet" "template_private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : tostring(idx) => cidr }

  vpc_id            = aws_vpc.template.id
  cidr_block        = each.value
  availability_zone = var.azs[tonumber(each.key)]

  tags = {
    Name = "${var.project}-private-${each.key}"
    Tier = "private"
  }
}

# NAT in first public subnet ("0")
resource "aws_eip" "city_of_anaheim_nat" {
  domain = "vpc"
  tags   = { Name = "${var.project}-nat-eip" }
}

resource "aws_nat_gateway" "city_of_anaheim" {
  allocation_id = aws_eip.city_of_anaheim_nat.id
  subnet_id     = aws_subnet.template_public["0"].id
  tags          = { Name = "${var.project}-nat" }

  depends_on = [aws_internet_gateway.template]
}

# Public route table -> IGW
resource "aws_route_table" "template_public" {
  vpc_id = aws_vpc.template.id
  tags   = { Name = "${var.project}-public-rt" }
}

resource "aws_route" "city_of_anaheim_public_internet" {
  route_table_id         = aws_route_table.template_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.template.id
}

# Private route table -> NAT
resource "aws_route_table" "template_private" {
  vpc_id = aws_vpc.template.id
  tags   = { Name = "${var.project}-private-rt" }
}

resource "aws_route" "template_private_nat" {
  route_table_id         = aws_route_table.template_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.city_of_anaheim.id
}

# Associations
resource "aws_route_table_association" "template_public_association" {
  for_each       = aws_subnet.template_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.template_public.id
}

resource "aws_route_table_association" "template_private_association" {
  for_each       = aws_subnet.template_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.template_private.id
}