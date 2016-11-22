# AWS Advent 2016 Demo Repository

This is the demo repository for my upcoming
[2016 AWS Advent](https://www.awsadvent.com/) article about Terraform modules.
It is a continuation of my previous article and repository found at the
following locations:

 * https://github.com/vancluever/packer-terraform-example
 * https://vancluevertech.com/2016/02/02/aws-world-detour-packer-and-terraform/

## The Components

 * A small ruby gem (`vancluever_hello`). This is built via rubygems tasks
   using `rake`.
 * A Chef recipe designed for deploying the application (`packer_payload`).
   This is a single-purpose cookbook that is not intended to be shared in
   Supermarket, etc. It's only intended for use with Packer. With that said,
   having a cookbook allows you to port this functionality to a general-use
   cookbook if necessary - this can then be included from a fresh
   `packer_payload` cookbook.
 * A packer template located at `packer/ami.json`.
 * Three Terraform examples:
  * The first one in the root `terraform/` directory is the main subject of the
    article.
  * Secondary examples exist in subdirectories of this one:
   * `terraform/multi_asg` sets up 2 unique ASGs,
   * `terraform/with_ssl` sets up the ASG with a SSL ALB. You need an IAM or ACM
     certificite and a Route 53 hosted zone to run this example.

The project uses 4 Terraform modules:

 * [`terraform_aws_vpc`](https://github.com/paybyphone/terraform_aws_vpc)
 * [`terraform_aws_alb`](https://github.com/paybyphone/terraform_aws_alb)
 * [`terraform_aws_asg`](https://github.com/paybyphone/terraform_aws_asg)
 * [`terraform_aws_security_group`](https://github.com/paybyphone/terraform_aws_security_group)

## The `Rakefile`

The `Rakefile` has tasks for managing the full lifecycle from building of the
gem, to AMI, to deployment. The list is below:

```
rake ami              # Create an application AMI with Packer
rake berks_cookbooks  # Vendors dependent cookbooks in berks-cookbooks (for Packer)
rake build            # Build vancluever_hello-0.1.1.gem into the pkg directory
rake clean            # Remove any temporary products
rake clobber          # Remove any generated files
rake infrastructure   # Deploy infrastructure using Terraform
rake kitchen          # Run test-kitchen on packer_payload cookbook
rake tf_modules       # Gets Terraform modules
```

In addition to that, the file also has helper functions for looking up
AMI IDs to be used in the build process.

## Using this Repository

To prepare the repository for use, clone it and run

```
bundle install --binstubs --path vendor/bundle
```

You should then be good to start using `bundle exec rake`. Get a list of
commands by running `bundle exec rake -T`.

You also need [Packer](https://www.packer.io/) and
[Terraform](https://www.terraform.io/).

Finally, valid AWS credentials will need to be available in your credential
chain, either as environment variables (ie: `AWS_ACCESS_KEY`,
`AWS_SECRET_ACCESS_KEY` and `AWS_SESSION_TOKEN`), or your credentials in your
`~/.aws` directory.

### Environment variables

You can also control the build process through the following environment
variables:

 * `DISTRO` To control the Ubuntu distribution to use (default `trusty`).
 * `REGION` To control the region to deploy to (default `us-east-1`).
 * `TF_CMD` To control the Terrafrom command (default `apply`. Change this to
   `destroy` to tear down the infrastructure).
 * `TF_DIR` To control the Terrafrom directory (default `terraform`, you would
   change this to `terraform/multi_asg` or `terraform/with_ssl` if you wanted to
   try the other examples).

## Author and License

```
Copyright 2016 Chris Marchesi

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
