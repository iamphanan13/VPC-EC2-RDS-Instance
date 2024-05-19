variable "aws_region" {
  default = "ap-southeast-1"
}


variable "vpc_cidr" {
  description = "CIDR Block for VPC"
  type = string 
  default = "10.10.0.0/16"
}

variable "rt_cidr" {
  description = "CIDR Block for Route Table"
  type = string
  default = "0.0.0.0/0"
}

# This variable will hold the number of private and public subnets
variable "subnet_count" {
    description = "Number of Subnets"
    type = map(number)
    default = {
      "public" = 1,
      "private" = 2
    }
}

# Configuration settins for the EC2 and RDS instances

variable "settings" {
  description = "Configuration EC2 and RDS"
  type = map(any)
  # type = map(object({
  #   database = map(object({
  #     instance_class = string
  #   }))
  # }))
  default = {
    "database" = {
        allocated_storage = 10 // Disk size 
        engine = "mysql" // Database engine
        engine_version = "8.0.27" // Database version
        instance_class = "db.t3.micro"
        db_name = "RDS_DB"
        skip_final_snapshot = true
    },
    "app" = {
        count = 1 
        instance_type = "t3.micro"
    }
  }
}


# Public subnets 

variable "public_subnets" {
  description = "Available CIDR for Public Subnets"
  type = list(string)
  default = [ 
    "10.10.1.0/24",
    "10.10.2.0/24",
    "10.10.3.0/24",
    "10.10.4.0/24"]
}

# Private subnets
variable "private_subnets" {
  description = "Available CIDR for Private Subnets"
  type = list(string)
  default = [ 
    "10.10.5.0/24",
    "10.10.6.0/24",
    "10.10.7.0/24",
    "10.10.8.0/24"]
}

variable "my_ip" {
  description = "My IP Address"
  type = string
  sensitive = true
}

# This variables contains the database username, will be storing in 
# The secret file
variable "db_username" {
  description = "Database user master"
  type = string
  sensitive = true
}

# This variables contains the database password, will be storing in
# The secret file

variable "db_password" {
  description = "Database master password"
  type = string
  sensitive = true
}


