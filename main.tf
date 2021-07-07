provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "dev-project-alfa-terraform-state"
    key    = "terraform.tfstate"
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
    Name  = "WebServer Project Alfa  - ${terraform.workspace}"
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
  tags = {
    Name  = "APPServer Project Alfa  - ${terraform.workspace}"
    Owner = "Roman"
  }
  depends_on = [aws_instance.WebServer]
}

resource "aws_instance" "Ansible" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_servers.id]
  provisioner "local-exec" {
    command = "ansible-playbook -u ec2-user -i '${aws_instance.Ansible.public_dns}' main.yml"
  }
  tags = {
    Name  = "Ansible Project Alfa  - ${terraform.workspace}"
    Owner = "Roman"
  }
  depends_on = [aws_instance.WebServer]
}

resource "aws_security_group" "my_servers" {
  name = "My Security Group - ${terraform.workspace}"
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
  tags = {
    Name  = "Project Alfa  - ${terraform.workspace}"
    Owner = "Roman"
  }
}
