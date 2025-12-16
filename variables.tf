variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}



variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
  default     = " ami-0ecb62995f68bb549"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for EC2"
  type        = string
  default     = "ec-gitlabci"
}

variable "profile" {
  type    = string
  default = "default"
}


  


  