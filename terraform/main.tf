# Use the AWS provider
provider "aws" {
  region = "ap-south-1"
}

# Add a variable for the Jenkins server's IP
variable "jenkins_server_ip" {
  type        = string
  description = "The public IP of the Jenkins server"
}

# Create a security group for the web server
resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allow inbound traffic for web access and SSH from Jenkins"

  # Rule to allow HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule to allow SSH traffic from the Jenkins server only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.jenkins_server_ip}/32"]
  }
}

# Define an EC2 instance and attach the security group
resource "aws_instance" "web_server" {
  ami           = "ami-07f07a6e1060cd2a8"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y openssh-server
              sudo systemctl start ssh
              sudo systemctl enable ssh
              EOF

  tags = {
    Name = "MyWebServer"
  }
}

# Output the public IP address of the web server
output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}
