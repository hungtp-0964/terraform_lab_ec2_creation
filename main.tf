variable "awsprops" {
    type = map
    default = {
    region = "ap-northeast-1"
    vpc = "vpc-02c5bf61bcfe1f62f"
    ami = "ami-088da9557aae42f39"
    itype = "t2.micro"
    subnet = "subnet-0e7512cf09e1eb26d"
    publicip = true
    secgroupname = "Test-Sec-Group"
  }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
  access_key = ""
  secret_key = ""
}


resource "aws_security_group" "ec2-test-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = lookup(var.awsprops, "vpc")

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "ec2-test-key" {
  key_name   = "terraform-demo"
  public_key = "${file("id_rsa.pub")}"
}

resource "aws_instance" "ec2-test" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = "${aws_key_pair.ec2-test-key.key_name}"


  vpc_security_group_ids = [
    aws_security_group.ec2-test-sg.id
  ]

  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "TEST"
  }

  depends_on = [ aws_security_group.ec2-test-sg ]
}

output "ec2instance" {
  value = aws_instance.ec2-test.public_ip
}
