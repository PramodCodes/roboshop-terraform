# we read ssm parameter store using data below
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id"
}