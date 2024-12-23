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

data "aws_ssm_parameter" "mongodb_sg_id" {
  name = "/${var.project_name}/${var.environment}/mongodb_sg_id"
}

# we will get 2 subnets because of HA , so we will use 1a , to get the 1a from list we use slice function 
# we will process this in locals
data "aws_ssm_parameter" "database_subnets_ids" {
  name = "/${var.project_name}/${var.environment}/database_subnets_ids"
}

