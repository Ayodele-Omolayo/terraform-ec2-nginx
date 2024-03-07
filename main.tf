provider "aws" {}

variable "cidr_blocks" {
  description = "subnet cidr blocks for vpc and subnet name"
  type = list(object({
    cidr_block = string
    name = string 
  }))
}

resource "aws_vpc" "dev-vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {
    Name: var.cidr_blocks[0].name
    vpc_env : "dev"
  }
  
}


resource "aws_subnet" "dev-subnet" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = "eu-west-1a"
    tags = {
      Name: var.cidr_blocks[1].name
    }
}



