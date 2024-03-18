provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_blocks
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
  
}

module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_blocks = var.subnet_cidr_blocks
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

# Use default security group

module "my-app-server" {
  source = "./modules/webserver"
  subnet_id = module.myapp-subnet.subnet.id
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  image_id = var.image_id
  instance_type = var.instance_type
  public_key_location = var.public_key_location
  private_key_location = var.private_key_location

}






