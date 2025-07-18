resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags   = { Name = "${var.name_prefix}-igw" }
}

resource "aws_eip" "elp" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elp.id
  subnet_id     = var.public_subnet_id
  tags          = { Name = "${var.name_prefix}-nat" }
}