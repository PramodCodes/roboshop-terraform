module "mongodb" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "mongodb"
    sg_description = "sg for mongodb"
    sg_ingress_rules = var.mongodb_sg_ingress_rules
   
}
