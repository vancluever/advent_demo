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

// vpc creates the VPC that will get created for our project.
module "vpc" {
  source                  = "github.com/paybyphone/terraform_aws_vpc"
  vpc_network_address     = "${var.vpc_network_address}"
  public_subnet_addresses = ["${var.public_subnet_addresses}"]
  project_path            = "${var.project_path}"
}

// alb creates the ALB that will get created for our project.
module "alb" {
  source              = "github.com/paybyphone/terraform_aws_alb"
  listener_subnet_ids = ["${module.vpc.public_subnet_ids}"]
  project_path        = "${var.project_path}"
}

// autoscaling_group creates the autoscaling group that will get created for
// our project.
//
// The ALB is also attached to this autoscaling group with the default /*
// path pattern.
module "autoscaling_group" {
  source           = "github.com/paybyphone/terraform_aws_asg"
  subnet_ids       = ["${module.vpc.public_subnet_ids}"]
  image_tag_value  = "vancluever_hello"
  enable_alb       = "true"
  alb_listener_arn = "${module.alb.alb_listener_arn}"
  alb_service_port = "4567"
  project_path     = "${var.project_path}"
}

output "alb_hostname" {
  value = "${module.alb.alb_dns_name}"
}
