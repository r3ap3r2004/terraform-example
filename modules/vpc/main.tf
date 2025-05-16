resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}${element(["a","b"], count.index)}"

  tags = {
    Name = "${var.name_prefix}-public-${count.index}"
  }
}

resource "aws_internet_gateway" "gw" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

# Default route → IGW
resource "aws_route" "default_igw" {
  count                  = var.create_internet_gateway ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw[0].id
}

# Associate each public subnet with the public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = var.create_internet_gateway ? aws_route_table.public[0].id : aws_vpc.main.main_route_table_id
}

output "vpc_id"          { value = aws_vpc.main.id }
output "public_subnets"  { value = aws_subnet.public[*].id }
output "igw_id"          { value = var.create_internet_gateway ? aws_internet_gateway.gw[0].id : null }
output "public_rt_id"    { value = var.create_internet_gateway ? aws_route_table.public[0].id   : null }
