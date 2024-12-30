provider "aws" {
  region = "ap-south-1"
  }

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_security_group" "sg" {
  name        = "assesment-security-group"
  description = "Allow HTTP and SSH"
  vpc_id      = "vpc-0b905ad752b8174f6" 

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_subnet" "subnet_a" {
  vpc_id                  = "vpc-0b905ad752b8174f6"  
  cidr_block              = "172.31.48.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = "vpc-0b905ad752b8174f6"  
  cidr_block              = "172.31.64.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
}

resource "aws_db_subnet_group" "main" {
  name        = "my-db-subnet-group"
  subnet_ids  = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]  
  description = "RDS DB Subnet Group covering multiple AZs"

  tags = {
    Name = "MyDBSubnetGroup"
  }
}

resource "aws_instance" "web_server" {
  ami             = "ami-053b12d3152c0cc71" 
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.sg.id]  

  tags = {
    Name = "WebServer"
  }
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "frontend-bucket-${random_string.suffix.result}"
}

resource "aws_s3_bucket_versioning" "frontend_bucket_versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_db_instance" "postgres" {
  identifier        = "my-postgres-db"
  engine            = "postgres"
  engine_version    = "PostgreSQL 15.4-R3"  
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  username          = "admin"
  password          = "Admin#123"
  db_name           = "mydatabase"
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.id
}

