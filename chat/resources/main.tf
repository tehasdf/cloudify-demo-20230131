# Specify the provider and access details
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "build" {
  connection {
    user = var.username
  }

  instance_type = "t2.medium"
  ami = var.ami

  key_name = var.key_name

  vpc_security_group_ids = ["sg-03b3b6c9ff0a450cb"]

  subnet_id = "subnet-b3fa87e9"
  user_data = file("userdata.sh")
}
