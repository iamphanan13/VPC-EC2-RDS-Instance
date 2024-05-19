# Create a VPC with custom name "vpc"
resource "aws_vpc" "vpc" {
  // Set the CIDR block for the VPC
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}

# Create an Internet Gateway with vpc_igw
resource "aws_internet_gateway" "vpc_igw" {
  // Set the VPC ID
  vpc_id = aws_vpc.vpc.id


  // Tagging the IGW
  tags = {
    Name = "VPC_IGW"
  }
}

# Create a group of public subnets based on variable subnet_count.public
resource "aws_subnet" "public_subnet" {
  // Count the number of resource want to create

  count = var.subnet_count.public

  // Set public subnet into VPC
  vpc_id = aws_vpc.vpc.id

  // Grabbing CIDR Block from the "public_subnets" variable, and grab element from the list based on count
  // When it count to 1, it will grab the first element from CIDR Block
  // It'll be 10.10.1.0/24

  cidr_block = var.public_subnets[count.index]

  // Grabbing avability zones from data object which created before, and grab element from the list based on count
  // When it count to 1, and my region is ap-southeast-1 and it'll grab ap-southeast-1a
  
  availability_zone = data.aws_availability_zones.available.names[count.index]

  // Adding tags to the public subnets and suffixed with the count
  tags = {
    Name = "Public_Subnet_${count.index}"
  }
}

# Create a group of private subnets based on variable subnet_count.private
resource "aws_subnet" "private_subnet" {
  // Count the number of resource want to create

  count = var.subnet_count.private

  // Set private subnet into VPC
  vpc_id = aws_vpc.vpc.id

  // Grabbing CIDR Block from the "private_subnets" variable, and grab element from the list based on count
  // When it count to 1, it will grab the first element from CIDR Block
  // It'll be 10.10.4.0/24

  cidr_block = var.private_subnets[count.index]

  // Grabbing avability zones from data object which created before, and grab element from the list based on count
  // When it count to 2, and my region is ap-southeast-1 and it'll grab ap-southeast-1b
  // Because the first azs is already used by the public subnet
  
  availability_zone = data.aws_availability_zones.available.names[count.index]

  // Adding tags to the private subnets and suffixed with the count
  tags = {
    Name = "Private_Subnet_${count.index}"
  }
}


resource "aws_route_table" "public_route_table" {
  // Put Public Route Table into my VPC 
  vpc_id = aws_vpc.vpc.id

  // Adding a route with a destination (0.0.0.0/0)
  // and adding GW "vpc_igw"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw
  }
}

resource "aws_route_table_association" "public" {
  // Current subnet_count.public is 1, so let's add the 1 public subnet
  count = var.subnet_count.public
  route_table_id = aws_route_table.public_route_table.id

  // Use count to grab the index and then grab the id of the subnet
  subnet_id = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table" "private_route_table" {
  // Put private Route Table into my VPC 
  vpc_id = aws_vpc.vpc.id

  // Here is private route table, then not adding route here
}

resource "aws_route_table_association" "private" {
  // Current subnet_count.private is 2, so let's add the 2 private subnet
  count = var.subnet_count.private
  route_table_id = aws_route_table.private_route_table.id

  // Use count to grab the index and then grab the id of the subnet
  subnet_id = aws_subnet.private_subnet[count.index].id
}

resource "aws_security_group" "web_sg" {
  name = "Web security group"
  description = "Security group for web servers"
  // This SG should be in "vpc" VPC
  vpc_id = aws_vpc.vpc.id

  # Open port 22 for EC2 Instance, this can be ssh via HTTP
  ingress {
    description = "Allow SSH through HTTP"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # This outbound rule is allowing traffic with EC2 Intances
  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web_SG"
  }
}

resource "aws_security_group" "db_sg" {
  name = "database_sg"
  description = "Security Group for Database"
  // the SG to be in the "vpc" VPC
  vpc_id = aws_vpc.vpc.id

  // Allow SSH from EC2 in the SG connect though port 3306,
  // and not allowing anywhere access from Internet, that why
  // i am not add any inbound/outbound rules outside traffic 
  ingress {
    description = "Allow MySQL from the security group only"
    from_port = "3306"
    to_port = "3306"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database_sg"
  }
}

# Create db subnet group
resource "aws_db_subnet_group" "db_sg" {
  name = "db_subnet_group"
  description = "Database subnet group"

  // subnet group requies at least 2 subnets, so i'm going to
  // loop through the private subnets  in "private_subnets" and
  // add them to this db subnet group

  subnet_ids = [for subnet in aws_subnet.private_subnet : subnet.id]
}

