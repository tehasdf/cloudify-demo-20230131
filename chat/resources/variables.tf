variable "key_name" {
  description = "A name for the key you are importing."
}

variable "public_key" {
  description = <<DESCRIPTION
Public Key Material.
DESCRIPTION
}

variable "aws_region" {
  description = "AWS region to launch servers."
}

variable "ami" {
  description = "ami to spawn"
}

variable "username" {
  description = "user to ssh as"
}
