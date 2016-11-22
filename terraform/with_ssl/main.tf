// Copyright 2016 Chris Marchesi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// The project path.
variable "project_path" {
  type    = "string"
  default = "vancluever/advent_demo"
}

// The IP space for the VPC.
variable "vpc_network_address" {
  type    = "string"
  default = "10.0.0.0/24"
}

// The IP space for the subnets within the VPC.
variable "public_subnet_addresses" {
  type    = "list"
  default = ["10.0.0.0/25", "10.0.0.128/25"]
}

// The hostname for your TLS endpoint.
variable "tls_endpoint" {
  type = "string"
}

// The Route 53 zone ID to add the TLS endpoint record to.
variable "route53_zone_id" {
  type = "string"
}

// The ARN for the certificate to load into the ALB (either IAM or ACM).
variable "certificate_arn" {
  type = "string"
}

// vpc creates the VPC that will get created for our project.
module "vpc" {
  source                  = "github.com/paybyphone/terraform_aws_vpc?ref=v0.1.0"
  vpc_network_address     = "${var.vpc_network_address}"
  public_subnet_addresses = ["${var.public_subnet_addresses}"]
  project_path            = "${var.project_path}"
}

// alb creates the ALB that will get created for our project.
module "alb" {
  source                   = "github.com/paybyphone/terraform_aws_alb?ref=v0.1.0"
  listener_subnet_ids      = ["${module.vpc.public_subnet_ids}"]
  listener_port            = "443"
  listener_protocol        = "HTTPS"
  listener_certificate_arn = "${var.certificate_arn}"
  project_path             = "${var.project_path}"
}

// autoscaling_group creates the autoscaling group that will get created for
// our project.
//
// The ALB is also attached to this autoscaling group with the default /*
// path pattern.
module "autoscaling_group" {
  source           = "github.com/paybyphone/terraform_aws_asg?ref=v0.1.1"
  subnet_ids       = ["${module.vpc.public_subnet_ids}"]
  image_tag_value  = "vancluever_hello"
  enable_alb       = "true"
  alb_listener_arn = "${module.alb.alb_listener_arn}"
  alb_service_port = "4567"
  project_path     = "${var.project_path}"
}

// route53_tls_endpoint_record creates a alias record set for the TLS
// endpoint within the supplied Route 53 zone ID.
resource "aws_route53_record" "route53_tls_endpoint_record" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.tls_endpoint}"
  type    = "A"

  alias {
    name                   = "${module.alb.alb_dns_name}"
    zone_id                = "${module.alb.alb_zone_id}"
    evaluate_target_health = true
  }
}

output "alb_hostname" {
  value = "${var.tls_endpoint}"
}
