#getting latest ami id automatically
data "aws_ami" "Centos8" {
    owners = ["973714476881"]
    most_recent = true
    
     filter {
    name   = "name"
    values = ["Centos-8-DevOps-Practice"]
    }
    filter {
    name   = "root-device-type"
    values = ["ebs"]
    }

    filter {
    name   = "virtualization-type"
    values = ["hvm"]
    }
}

data "aws_vpc" "default_vpc_info" {
  default = true
}

output "default_vpc_info" {
  value = data.aws_vpc.default_vpc_info
}