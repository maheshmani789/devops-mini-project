# Use the AWS provider
provider "aws" {
  region = "ap-south-1"
}

# Define an EC2 instance
resource "aws_instance" "web_server" {
  # !!! IMPORTANT: Replace this with a valid Ubuntu AMI ID for your region !!!
  # You can find one in the AWS EC2 launch wizard.
  ami           = "ami-07f07a6e1060cd2a8"
  instance_type = "t2.micro"
  tags = {
    Name = "MyWebServer"
  }
}

# Output the public IP address of the server
output "server_ip" {
  value = aws_instance.web_server.public_ip

}
