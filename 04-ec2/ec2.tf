module "mongodb" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.Centos8.id

  name = "${local.ec2_name}-mongodb"

  instance_type          = "t3.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.mongodb_sg_id.value]
# if you dont clealy metion .value you wont get the value since its an object you will see error
  subnet_id              = local.database_subnet_id

  tags = merge(
    var.common_tags,
    {
        Componenet = "mongodb"
    },{
        Name = "${local.ec2_name}-mongodb"
    })
}