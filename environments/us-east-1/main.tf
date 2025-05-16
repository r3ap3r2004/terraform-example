terraform {
  required_version = ">= 1.6.0"
}

locals {
  web_ingress  = jsondecode(file("${path.module}/../../sg_rules/web_ingress.json"))
  web_egress   = jsondecode(file("${path.module}/../../sg_rules/web_egress.json"))
  mysql_ingress = jsondecode(file("${path.module}/../../sg_rules/mysql_ingress.json"))
  mysql_egress  = jsondecode(file("${path.module}/../../sg_rules/mysql_egress.json"))
}

module "vpc" {
  source      = "../../modules/vpc"
  cidr_block  = var.vpc_cidr
  name_prefix = var.name_prefix
  region      = var.region
}

# Security groups
module "sg_web" {
  source      = "../../modules/sg"
  name_prefix = var.name_prefix
  role        = "web"
  vpc_id      = module.vpc.vpc_id
  ingress     = local.web_ingress
  egress      = local.web_egress
}

module "sg_mysql" {
  source      = "../../modules/sg"
  name_prefix = var.name_prefix
  role        = "mysql"
  vpc_id      = module.vpc.vpc_id
  ingress     = local.mysql_ingress
  egress      = local.mysql_egress
  sg_ingress = [
    {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
      source_sg = module.sg_web.id
    }
  ]
}

# IAM roles example
module "iam_web" {
  source      = "../../modules/iam"
  name_prefix = var.name_prefix
  service     = "web"
}
module "iam_mysql" {
  source      = "../../modules/iam"
  name_prefix = var.name_prefix
  service     = "mysql"
}

# S3 buckets for backups
module "s3" {
  source = "../../modules/s3"
  bucket_names = [
    "${var.name_prefix}-${terraform.workspace}-web-backups",
    "${var.name_prefix}-${terraform.workspace}-mysql-backups"
  ]
}

# EC2 Instances
data "template_file" "web_userdata" {
  template = file("${path.module}/../../user_data/webserver/user_data.sh")
}
data "template_file" "mysql_userdata" {
  template = file("${path.module}/../../user_data/mysqlserver/user_data.sh")
}
data "template_file" "ssh_cloudinit" {
  template = file("${path.module}/../../user_data/authorized_keys.yml")
}

# If you already created a key pair in the AWS console, just set:
variable "ssh_key_name" { default = "" }

# …or let Terraform create it for you from a public-key file:
resource "aws_key_pair" "this" {
  key_name   = "${var.name_prefix}-${terraform.workspace}"
  public_key = file("~/.ssh/id_rsa.pub")
}


module "ec2_web" {
  source        = "../../modules/ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[0]
  sg_ids        = [module.sg_web.id]
  name_prefix   = var.name_prefix
  role          = "web"
  user_data     = join("\n", [
    data.template_file.ssh_cloudinit.rendered,
    data.template_file.web_userdata.rendered
  ])
  key_name      = var.ssh_key_name != "" ? var.ssh_key_name : aws_key_pair.this.key_name

}

module "ec2_mysql" {
  source        = "../../modules/ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[1]
  sg_ids        = [module.sg_mysql.id]
  name_prefix   = var.name_prefix
  role          = "mysql"
  user_data     = join("\n", [
    data.template_file.ssh_cloudinit.rendered,
    data.template_file.mysql_userdata.rendered
  ])
  key_name      = var.ssh_key_name != "" ? var.ssh_key_name : aws_key_pair.this.key_name
}

# DNS Records
module "dns_web" {
  source  = "../../modules/dns"
  zone_id = var.route53_zone_id
  name    = "web.${terraform.workspace}.${var.domain}"
  ip      = module.ec2_web.public_ip
}
module "dns_mysql" {
  source  = "../../modules/dns"
  zone_id = var.route53_zone_id
  name    = "db.${terraform.workspace}.${var.domain}"
  ip      = module.ec2_mysql.public_ip
}
