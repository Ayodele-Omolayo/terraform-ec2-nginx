provider "aws" {
  region = "eu-west-1"
}

variable "vpc_cidr_blocks" {}
variable "subnet_cidr_blocks" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my-ip" {}
variable "public_key_location" {}
variable "private_key_location" {}



resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_blocks
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
  
}
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.avail_zone
    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
  
}

# resource "aws_route_table" "myapp-route-table" {
#   vpc_id = aws_vpc.myapp-vpc.id
  
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
     
#   }
#   tags = {
#     Name: "${var.env_prefix}-rtb"
#   }
# }


# resource "aws_route_table_association" "a-rtb-subnet" {
#   subnet_id = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.myapp-route-table.id
  
# }

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id 
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
  
}

# create aws security groups
# resource "aws_security_group" "myapp-sg" {
#   name = "myapp-sg"
#   vpc_id = aws_vpc.myapp-vpc.id
#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [ var.my-ip ]
#   }
#   ingress {
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]

#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     prefix_list_ids = []
    
#   }
#    tags = {
#     Name: "${var.env_prefix}-sg"
#   }
  
# }



# Use default security group
resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
    
  }
   tags = {
    Name: "${var.env_prefix}-default-sg"
  }
  
}

# data "aws_ami" "latest-amazon-linux-machine" {
#   most_recent = true
#   owners = [ "137112412989" ]
#   filter {
#     name = "name"
#     values = [ "al2023-ami-2023.3.20240304.0-kernel-6.1-*" ]
    
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
  
# }

# resource "aws_key_pair" "ssh-key" {
#   key_name   = "server-key"
#   public_key = file(var.public_key_location)
  
# }


resource "aws_key_pair" "deployer" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
  
}


resource "aws_instance" "myapp-server" {
  ami = "ami-074254c177d57d640"
  instance_type = "t2.micro"
   
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.key_name

  user_data = file("entry-script.sh")

# Using provisions
  # connection{
  #   type = "ssh"
  #   host = self.public_ip
  #   user = "ec2-user"
  #   private_key = file(var.private_key_location)
  # }

  # provisioner "file" {
  #   sources = "entry-script.sh"
  #   destination = "/home/ec2-user/entry-script-on-ec2.sh"

  # }
  # provisioner "remote-exec" {
  #   script = file("entry-script-on-ec2 .sh")
  # }
 
  tags = {
    Name :"${var.env_prefix}-instance"
    foo : "bar"
  }
}



output "public_key" {
  value = aws_instance.myapp-server.public_ip

}




