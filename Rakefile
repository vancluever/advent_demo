# Copyright 2016 Chris Marchesi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'bundler/gem_tasks'
require 'ubuntu_ami'
require 'vancluever_hello/version'

# Return a default distro if not defined
def distro
  if ENV.include?('DISTRO')
    ENV['DISTRO']
  else
    'xenial'
  end
end

# Return a default region if not defined
def region
  if ENV.include?('REGION')
    ENV['REGION']
  else
    'us-west-2'
  end
end

# Return a default Terraform command if not defined
def tf_cmd
  if ENV.include?('TF_CMD')
    ENV['TF_CMD']
  else
    'apply'
  end
end

# Get an ubuntu AMI ID to build off of (for Packer)
def ubuntu_ami_id
  Ubuntu.release(distro).amis.find do |ami|
    ami.arch == 'amd64' &&
      ami.root_store == 'ebs-ssd' &&
      ami.virtualization_type == 'hvm' &&
      ami.region == region
  end.name
end

# Make sure I don't release/push this to rubygems by mistake
Rake::Task['release'].clear

# Also no system install
Rake::Task['install:local'].clear
Rake::Task['install'].clear

desc 'Vendors dependent cookbooks in berks-cookbooks (for Packer)'
task :berks_cookbooks do
  sh 'rm -rf berks-cookbooks'
  sh 'berks vendor -b cookbooks/packer_payload/Berksfile'
end

desc 'Gets Terraform modules'
task :tf_modules do
  sh 'terraform get -update terraform'
end

desc 'Create an application AMI with Packer'
task :ami => [:build, :berks_cookbooks] do
  sh "DISTRO=#{distro} \
   SRC_AMI=#{ubuntu_ami_id} \
   SRC_REGION=#{region} \
   APP_VERSION=#{VanclueverHello::VERSION} \
   packer build packer/ami.json"
end

desc 'Deploy infrastructure using Terraform'
task :infrastructure => [:tf_modules] do
  sh "AWS_DEFAULT_REGION=#{region} \
   terraform #{tf_cmd} terraform"
end

desc 'Run test-kitchen on packer_payload cookbook'
task :kitchen do
  sh "cd cookbooks/packer_payload && \
   KITCHEN_YAML=.kitchen.cloud.yml \
   AWS_KITCHEN_AMI_ID=#{ubuntu_ami_id} \
   AWS_KITCHEN_USER=ubuntu \
   AWS_REGION=#{region} \
   KITCHEN_APP_VERSION=#{VanclueverHello::VERSION} \
   kitchen test"
end
