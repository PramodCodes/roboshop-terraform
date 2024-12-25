module "open_vpn" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_vpc.default_vpc_info.id
    sg_name = "vpn"
    sg_description = "sg for vpn"
    # sg_ingress_rules = var.mongodb_sg_ingress_rules
}
module "mongodb" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "mongodb"
    sg_description = "sg for mongodb"
    # sg_ingress_rules = var.mongodb_sg_ingress_rules
}

module "catalogue" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "catalogue"
    sg_description = "sg for catalogue"
}
module "cart" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "cart"
    sg_description = "sg for cart"
}
module "user" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "user"
    sg_description = "sg for user"
}
module "shipping" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "shipping"
    sg_description = "sg for shipping"
}

module "payment" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "payment"
    sg_description = "sg for payment"
}

module "ratings" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "ratings"
    sg_description = "sg for ratings"
}

#DB tier
module "redis" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "redis"
    sg_description = "sg for redis"
}

module "mysql" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "mysql"
    sg_description = "sg for mysql"
}

module "rabbitmq" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "rabbitmq"
    sg_description = "sg for rabbitmq"
}
module "web" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "web"
    sg_description = "sg for web"
}
# security group rules using convention which-sg-should-be-added_in-which-sg outgoing-connnections_incoming-connections
# connections 
# catalogue_mongodb
# user_mongodb
# cart_redis
# user_redis
# shipping_mysql
# ratings_mysql
# payment_rabbitmq
# first rule is for vpn
resource "aws_security_group_rule" "home_vpn" {
  //TODO add name tag seems complicated
  security_group_id = module.open_vpn.sg_id 
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] #ideally your home ip address , since we dont have static ip we are using this 
}

# since mongo db is allowing connection from catalogue we use name as catalogue_mongodb
resource "aws_security_group_rule" "catalogue_mongodb" {
  //TODO add name tag seems complicated
  source_security_group_id = module.catalogue.sg_id # we are accepting connection from catalogue
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  security_group_id = module.mongodb.sg_id #adding sg of catalogue in mongodb from catalogue
}

# since mongo db is allowing connection from user we use name as user_mongodb

resource "aws_security_group_rule" "user_mongodb" {
  source_security_group_id = module.user.sg_id # we are accepting conenction from user 
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  security_group_id = module.mongodb.sg_id #adding sg of user in mongodb from user
}

resource "aws_security_group_rule" "cart_redis" {
  source_security_group_id = module.cart.sg_id 
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  security_group_id = module.redis.sg_id 
}

resource "aws_security_group_rule" "user_redis" {
  source_security_group_id = module.user.sg_id
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = module.redis.sg_id 
}

# shipping_mysql
resource "aws_security_group_rule" "shipping_mysql" {
  source_security_group_id = module.shipping.sg_id
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = module.mysql.sg_id 
}
# ratings_mysql
resource "aws_security_group_rule" "ratings_mysql" {
  source_security_group_id = module.ratings.sg_id
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = module.mysql.sg_id 
}
# payment_rabbitmq
resource "aws_security_group_rule" "payment_rabbitmq" {
  source_security_group_id = module.payment.sg_id 
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = module.rabbitmq.sg_id 
}