variable "common_tags" {
    default = {
        Project = "roboshop"
        Environment = "dev"
        Terraform = true
    }
}

variable "sg_tags" {
    default = {}
}

variable "project_name" {
    default = "roboshop"
    type = string
}

variable "environment" {
    default = "dev"
    type = string
}
