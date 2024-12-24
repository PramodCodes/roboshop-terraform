data "aws_ssm_parameter" "mongodb_sg_id" {
  name = "/${var.project_name}/${var.environment}/mongodb_sg_id"
}

# we will get 2 subnets because of HA , so we will use 1a , to get the 1a from list we use slice function 
# we will process this in locals
data "aws_ssm_parameter" "database_subnets_ids" {
  name = "/${var.project_name}/${var.environment}/database_subnets_ids"
}