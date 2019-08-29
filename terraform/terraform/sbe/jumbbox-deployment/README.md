# Jumpbox Deployment

## Usage Example

Change module name value from "your_jumpbox" by replacing 'yourName' and append to end of main.tf within this folder. The scripts for the EC2 configuration is located in a subfolder within this directory /bootstrap. Copy the example.sh and make appropariate changes and rename to your name.

```
module "yourName_jumpbox" {
  source = "../../modules/jump_box"

  key_name              = "youName"
  key_path              = "/home/USER/.ssh/sshkey.pem"
  subnet_id             = element(tolist(data.aws_subnet_ids.public.ids), 0)
  vpc_name                = var.vpc_name
  operator_name         = "yourName"
  bootstrap_script_path = "bootstrap/yourName.sh"
  security_group_id     = aws_security_group.jumpbox_sg.id
}

```

### Why isn't this in the root main.tf?

I wanted to separate this terrafrom so that if a change needs to be made on a jumpbox, it doesn't risk affecting the entire environment.

### Important note for Terraform Destroy from root AWS directory

In AWS it is not possible to destroy an existing IGW or route that an object is using. In terraform a destroy operation will repeatedly try without failure because it is incapable of reporting the AWS CLI failure message that there is something using the IGW or route. Because the jumpbox deployment terrafrom is outside of the root directory, it is best practice to either destroy from a pipeline to account for order of operation problems such as this, or to remain mindful of this issue and acknowledge that a longer than average destroy likely means that there is something using that resource in AWS and must be removed first.

### Update bootstrap script

It will be necessary to copy the example.sh located within the /bootstrap directory and make changes where indicated in GIT configuration;

```
#!/usr/bin/env bash

set -e
#change/set versions of software here
FLY_CLI_VERSION='5.2.0'
CREDHUB_CLI_VERSION='2.4.0'
TERRAFORM_VERSION='0.12.1'

# Update and install basics
sudo apt-get update
sudo apt-get -y install jq unzip

# Install AWS CLI
sudo apt-get -y install awscli

# Configure git, change values for your account
git config --global user.name "YOUR_NAME"                 #<=Change Here
git config --global user.email "YOUR_EMAIL@DOMAIN.COM"    #<=Change Here

# Instals fly CLI
wget https://github.com/concourse/concourse/releases/download/v${FLY_CLI_VERSION}/fly-${FLY_CLI_VERSION}-linux-amd64.tgz
tar -xvf fly-${FLY_CLI_VERSION}-linux-amd64.tgz
chmod +x fly
sudo mv fly /usr/local/bin/

#Install Credhub CLI
wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_VERSION}/credhub-linux-${CREDHUB_CLI_VERSION}.tgz
tar -zxvf credhub-linux-${CREDHUB_CLI_VERSION}.tgz
rm credhub-linux-${CREDHUB_CLI_VERSION}.tgz
sudo mv  credhub /usr/local/bin/credhub

# Install Terraform
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/

```

### SSH into your jumpbox

The default user account for the Canonical Ubuntu Bionic image is *ubuntu*.

If a key other than the default was used, it'll be necessary to specify the key path with -i;

```
ssh -i /home/user/.ssh/alt_key/not_default.pem ubuntu@0.0.0.0
```



