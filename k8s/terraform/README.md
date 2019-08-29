# K8s Terraform Repo

This repo contains various aspects of automation between AWS and VMware vSphere along with modules for both.

Each subsequent repo will have their own readme documentation and should be referenced for any issues or need that may arise.

## Installing Terraform

To install Terraform, find the [appropriate package](https://www.terraform.io/downloads.html) for your system and download it. Terraform is packaged as a zip archive.

After downloading Terraform, unzip the package. Terraform runs as a single binary named `terraform`. Any other files in the package can be safely removed and Terraform will still function.

The final step is to make sure that the `terraform` binary is available on the `PATH`. See [this page](https://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux)for instructions on setting the PATH on Linux and Mac. [This page](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows) contains instructions for setting the PATH on Windows.

## Verifying the Installation

After installing Terraform, verify the installation worked by opening a new terminal session and checking that `terraform` is available. By executing `terraform` you should see help output similar to this:

```
$ terraform
Usage: terraform [--version] [--help] <command> [args]

The available commands for execution are listed below.
The most common, useful commands are shown first, followed by
less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the
other commands, please read the help and docs before usage.

Common commands:
    apply              Builds or changes infrastructure
    console            Interactive console for Terraform interpolations
# ...
```

If you get an error that `terraform` could not be found, your `PATH` environment variable was not set up properly. Please go back and ensure that your `PATH` variable contains the directory where Terraform was installed.

**State File**

There is a need to have a state file that becomes the source of truth for terraform to successfully deploy a platform without the need to repave an entire existing platform. In order to prevent overwriting state files between multiple operators, terraform provides a method called 'backend' to set where a shared state file (terrafrom.tfstate) can be used for a consistent terraform run.

We place our state file into an AWS S3 bucket. The blocks of code necessary to do so is to state the provider, in this case AWS and invoke backend;

```
provider "aws" {

  region  = "us-gov-west-1"

  profile = "some_profile"

}

terraform {

  backend "s3" {

    bucket = "to/my/bucket"

    key = "terraform/aws/terrafrom.tfstate"

    region = "us-gov-west-1"

    profile = "some_profile"

  }

}
```

The first block is calling the AWS profile that you designate which stores access and secret key in a hidden folder which in the case of Nix and Mac is 

```
~/.aws/credentials
```

In the second block the bucket and folder paths within need to be stated, key refers to the name and location of a state file that will be automatically created by terraform, and it may be necessary to state '*profile =*' if you have custom profiles as terraform will default to the 'default' profile within the AWS credentials file.

Run *terraform plan* to validate and if it comes back looking for a state file, run *terraform init*. Keep in mind that init command can be run as many times as necessary. If any issues arise, toubleshooting is easier with verbose output with T*F_LOG=debug terraform init*

**AWS S3**

It is necessary to configure S3 for terraform to be able to read/write to the bucket where the state file will be kept. Simplest way is to apply the following policy. Be sure to replace *numeric_aws_acct_number* and *myBucket*;

```
    "Version": "2012-10-17",

​    "Statement": [

​        {

​            "Effect": "Allow",

​            "Action": "s3:ListBucket",

​            "Principal": {

​                "AWS": "arn:aws-us-gov:iam::numeric_aws_acct_number:root"

​            },

​            "Resource": "arn:aws-us-gov:s3:::myBucket"

​        },

​        {

​            "Effect": "Allow",

​            "Action": [

​                "s3:GetObject",

​                "s3:PutObject"

​            ],

​            "Principal": {

​                "AWS": "arn:aws-us-gov:iam::numeric_aws_acct_number:root"

​            },

​            "Resource": "arn:aws-us-gov:s3:::myBucket/terraform"

​        }

​    ]

}
```

**Okta SSO**

*okta-aws some_profile sts get-caller-identity*

Test: *aws --profile some_profile s3api list-buckets*

