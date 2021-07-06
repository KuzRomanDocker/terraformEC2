provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "dev-project-alfa-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "WebServer" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_servers.id]
  user_data = templatefile("user_data.tpl", {
    f_name = "Roman",
    l_name = "Kuznetsov",
    cars   = ["Volvo", "BMW", "Mercedes", "AUDI", "Ferrari", "Bugatti"]
  })
  tags = {
    Name  = "Project Alfa"
    Owner = "Roman"
  }
}

resource "aws_instance" "APPServer" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_servers.id]
  user_data              = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>WebServer with IP: $myip</h2><br>APP Server" > /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd
EOF
  tags                   = merge(var.common-tags, { Name = "${var.common-tags["Envrironment"]} Alfa" })
  depends_on             = [aws_instance.WebServer]
}

resource "aws_security_group" "my_servers" {
  name = "My Security Group"
  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common-tags, { Name = "${var.common-tags["Envrironment"]} Server IP" })
}
