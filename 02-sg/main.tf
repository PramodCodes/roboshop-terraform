# This file is used to create security groups for each service in the project

## DB tier
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

# microservices tier
module "catalogue" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "catalogue"
    sg_description = "sg for catalogue"
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

module "cart" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "cart"
    sg_description = "sg for cart"
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

# web tier
module "web" {
    source = "../../terraform-aws-security-group"
    project_name = var.project_name
    environment = var.environment

    #lets use data source for vpc
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_name = "web"
    sg_description = "sg for web"
}


# vpn tier
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


# security group rules using convention which-sg-should-be-added_in-which-sg outgoing-connnections_incoming-connections
# connections 
# catalogue_mongodb
# user_mongodb
# cart_redis
# user_redis
# shipping_mysql
# ratings_mysql
# payment_rabbitmq

# vpn tier
# first rule is for vpn
resource "aws_security_group_rule" "home_vpn" {
  //TODO add name tag seems complicated
  security_group_id = module.open_vpn.sg_id 
  type              = "ingress"
  from_port         = 0 # chaning port 22 to all ports because we are using vpn which needs 1194 port 
  to_port           = 0
  protocol          = "-1" #"tcp" to allow all ports protocol is -1
  cidr_blocks = ["0.0.0.0/0"] #ideally your home ip address , since we dont have static ip we are using this 
}

# DB tier
# mongodb must accept connection from vpn , catalogue and user
resource "aws_security_group_rule" "vpn_mongodb" {
  //TODO add name tag seems complicated
  source_security_group_id = module.open_vpn.sg_id # we are accepting connection from vpn
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.mongodb.sg_id #
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

# redis must accept connection from vpn, cart and user

resource "aws_security_group_rule" "vpn_redis" {
  source_security_group_id = module.open_vpn.sg_id 
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.redis.sg_id 
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
resource "aws_security_group_rule" "vpn_mysql" {
  source_security_group_id = module.open_vpn.sg_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.mysql.sg_id 
}
resource "aws_security_group_rule" "shipping_mysql" {
  source_security_group_id = module.shipping.sg_id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = module.mysql.sg_id 
}

# vpn_rabbitmq , payment_rabbitmq
resource "aws_security_group_rule" "vpn_rabbitmq" {
  source_security_group_id = module.open_vpn.sg_id 
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.rabbitmq.sg_id 
}
resource "aws_security_group_rule" "payment_rabbitmq" {
  source_security_group_id = module.payment.sg_id 
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = module.rabbitmq.sg_id 
}

# microservices tier ingress rules
# - catalogue
# - user
# - cart
# - shipping
# - payment

# - catalogue:
#   - name: catalogue_vpn=>vpn_catalogue
#     purpose: catalogue should accept traffic on 22 from vpn
#   - name: catalogue_web=>web_catalogue
#     purpose: catalogue should accept traffic on 8080 from web
#   - name: catalogue_cart=>cart_catalogue
#     purpose: catalogue should accept traffic on 8080 from cart
resource "aws_security_group_rule" "vpn_catalogue" {
  source_security_group_id = module.open_vpn.sg_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.catalogue.sg_id 
}

resource "aws_security_group_rule" "web_catalogue" {
  source_security_group_id = module.web.sg_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.catalogue.sg_id 
}
resource "aws_security_group_rule" "cart_catalogue" {
  source_security_group_id = module.cart.sg_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.catalogue.sg_id 
}
# - user:
#   - name: user_vpn=>vpn_user
#     purpose: user should accept traffic on 22 from vpn
#   - name: user_web=>web_user
#     purpose: user should accept traffic on 8080 from web
#   - name: user_payment=>payment_user
#     purpose: user should accept traffic on 8080 from payment

resource "aws_security_group_rule" "vpn_user" {
  source_security_group_id = module.open_vpn.sg_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.user.sg_id 
}
resource "aws_security_group_rule" "web_user" {
  source_security_group_id = module.web.sg_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.user.sg_id 
}
resource "aws_security_group_rule" "payment_user" {
  source_security_group_id = module.payment.sg_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.user.sg_id 
}
# - cart:
#   - name: cart_vpn=>vpn_cart
#     purpose: cart should accept traffic on 22 from vpn
#   - name: cart_web=>web_cart
#     purpose: cart should accept traffic on 8080 from web
#   - name: cart_shipping=>shipping_cart
#     purpose: cart should accept traffic on 8080 from shipping
#   - name: cart_payment=>payment_cart
#     purpose: cart should accept traffic on 8080 from payment
resource "aws_security_group_rule" "vpn_cart" {
  source_security_group_id = module.open_vpn.sg_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.cart.sg_id 
}
resource "aws_security_group_rule" "web_cart" {
  source_security_group_id = module.web.sg_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.cart.sg_id 
}
resource "aws_security_group_rule" "shipping_cart" {
  source_security_group_id = module.shipping.sg_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.cart.sg_id 
}
resource "aws_security_group_rule" "payment_cart" {
  source_security_group_id = module.payment.sg_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.cart.sg_id 
}

# - shipping:
#   - name: shipping_vpn=>vpn_shipping
#     purpose: shipping should accept traffic on 22 from vpn
#   - name: shipping_web=>web_shipping
#     purpose: shipping should accept traffic on 8080 from web

resource "aws_security_group_rule" "vpn_shipping" {
  source_security_group_id = module.open_vpn.sg_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.shipping.sg_id 
}
resource "aws_security_group_rule" "web_shipping" {
  source_security_group_id = module.web.sg_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.shipping.sg_id 
}
# - payment:
#   - name: payment_vpn=>vpn_payment
#     purpose: payment should accept traffic on 22 from vpn
#   - name: payment_web=>web_payment
#     purpose: payment should accept traffic on 8080 from web

resource "aws_security_group_rule" "vpn_payment" {
  source_security_group_id = module.open_vpn.sg_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.payment.sg_id 
}
resource "aws_security_group_rule" "web_payment" {
  source_security_group_id = module.web.sg_id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.payment.sg_id 
}

# web tier
# web:- name: web_vpn=>vpn_web
#   purpose: web should accept traffic on 22 from vpn
# - name: web_internet=>web_internet
#   purpose: web should accept traffic on 80 from internet

resource "aws_security_group_rule" "vpn_web" {
  source_security_group_id = module.open_vpn.sg_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.web.sg_id 
}
resource "aws_security_group_rule" "web_internet" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web.sg_id 
}

# ratings_mysql this is not in documentation skipping this rule
# resource "aws_security_group_rule" "ratings_mysql" {
#   source_security_group_id = module.ratings.sg_id
#   type              = "ingress"
#   from_port         = 6379
#   to_port           = 6379
#   protocol          = "tcp"
#   security_group_id = module.mysql.sg_id 
# }