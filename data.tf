data "aws_ami" "ubuntu_2404" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_availability_zones" "azs" {
  state = "available"
}

#Get already , publicly configured Hosted Zone on Route53 - MUST EXIST, check variables.tf for dns-name
data "aws_route53_zone" "dns" {
  name     = var.dns-name
}