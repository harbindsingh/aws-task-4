provider "aws" {
  region = "ap-south-1"
  profile = "jass"
}

resource "aws_vpc" "myvpc1" {
  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  
  tags = {
    Name = "tera-vpc"
   }    
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.myvpc1.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
   Name = "public-subnet"
   }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.myvpc1.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "mygw" {
  vpc_id = aws_vpc.myvpc1.id

  tags = {
    Name = "tera-gw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc1.id
  
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygw.id
   }

     tags = {
    Name = "hs_routetable"
  } 
}
resource "aws_route_table_association" "rt_public_subnet" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "allow_ssh" {
 name = "allow_ssh"
 vpc_id = aws_vpc.myvpc1.id
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "public_sg"
  }
}
 
resource "aws_security_group" "allow_mysql" {
 name = "allow_mysql"
 vpc_id = aws_vpc.myvpc1.id
  
  ingress {
    description = "MYSQL-rule"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "private_sg"
  }
}
 
resource "aws_instance" "wordpress" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name = "mykey111222"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "wordpress"
  }
}

resource "aws_instance" "MySQL" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
  key_name = "mykey111222"
  availability_zone = "ap-south-1b"


 tags = {
    Name = "mysql"
  }
} 