## Terraform SBE for K8s

The stack used are;

- Terraform
- Packer
- Concourse
- Bash
- AWS Snowball Edge CLI
- AWS CLI

### AWS Snowball Edge (SBE)

The SBE is a physical device offered as part of the AWS service as a service. To procure a SBE, you must log into the AWS console and create a 'job' which ends in an order to ship a unit out. The SBE ships locked to prevent unwanted access and potential injection of malicious software in transit. Once received the unit must be unlocked. 

First thing is to plug the SBE into power and network. There is an option for DHCP, but here we must assign static addresses for the server segmented network. The IP is entered via the touch screen on the SBE (It's a Amazon Fire Tablet embedded) and truth be told not the best experience as the screen is small and not in the best location to finger type a static IP, mask, and gateway. Once done hit apply and it looks like it takes the info, but the apply button remains available and you can keep hitting apply...only sure way to know it's working is to ping the assigned IP.

For ease the snowball and snowball edge CLI client for Linux has been pre-downloaded and added to this repo. If other OS versions are needed they can be downloaded from AWS. Within the SBE directory you will find a snowball_client directory and within versions. For the commands to work, it's recommended to CD to the version and the bin directory within. Prior to unlocking the device it's best to run *./snowballEdge configure* and enter the manifest file path and unlock code, both available from the SBE job page on the AWS web console. For sake of simplicity, it's recommended to download the manifest file to the same path as the bin directory, with future iteration to leverage credentials storage and management such as Hashicorp Vault. 

The linux documentation omits an important detail compared to the examples listed in AWS documentation, it wasn't clear or obvious that linux users must run the command as ./snowball or ./snowballEdge pending the device. The documentation can be found at <https://github.com/awsdocs/aws-snowball-developer-guide/blob/master/doc_source/common-get-start.md>

Unlocking the device is done via the *./snowballEdge unlock-device* command. I've experienced 50/50 where the configuration was read from *./snowballEdge configure* and didn't need to verbosely enter unlock code, manifest path, and device IP, but YMMV.

Once unlocked it is advisable to set up a virtual IP on the device. Once the virtual IP is established, you'll see a json return of what the completed set up looks like,

```
{
  "VirtualNetworkInterface" : {
    "VirtualNetworkInterfaceArn" : "arn:aws:snowball-device:::interface/s.ni-83b73fa8650be15bc",
    "PhysicalNetworkInterfaceId" : "s.ni-8e47fb34c8e9d6383",
    "IpAddressAssignment" : "STATIC",
    "IpAddress" : "10.1.100.211",
    "Netmask" : "255.255.255.0",
    "DefaultGateway" : "10.1.100.1",
    "MacAddress" : "1e:fe:3f:30:19:5a"
  }
}
```

The virtual IP is useful where it is easier to click and drag files to the SBE versus via CLI. To have that service available, it'll need to be started with *./snowballEdge start-service* and filter with the switch *--service-id* for which service you intend to start, in this case the service ID is f*ileinterface*. A list of available services on your SBE can be queried with *./snowballEdge list-services*. Starting the fileinterface service also requires knowing the virtual network ARN which can be gathered with .*/snowballEdge describe-virtual-network-interfaces*. 

Virtual IPs are also necessary for compute instances to have an externally facing IP. There is one additional step to use virtual IPs with a compute instance and that is to associate the IP with ED2 usage;

```
aws ec2 associate-address --public-ip 192.0.2.0 --instance-id s.i-01234567890123456 --endpoint <physical IP address for your Snowball Edge>:8008
```

Example for configuring the SBE with a virtual IP specific to Mad Hatter looks like this, save for the device interface ID;

```
snowballEdge create-virtual-network-interface \
--physical-network-interface-id s.ni-8e47fb34c8e9d6383 \
--ip-address-assignment STATIC \
--static-ip-address-configuration IpAddress=10.1.100.211,Netmask=255.255.255.0
```

It's worth checking with the *describe-services --service-id* switch to ensure that all expected services are actually running.

There are additional set up necessary to use the compute within the SBE that isn't well documented. The first of which is to retrieve the access key unique to the SBE (Windows and Mac should be able to omit ./ on all commands);  

```
./snowballEdge list-access-keys
```

The command should return something like this;

```
{
  "AccessKeyIds" : [ "ABCDEFGHIJKLMNOPQ1ST" ]
}
```

Copy the key ID and run;

```
./snowballEdge get-secret-access-key --access-key-id ABCDEFGHIJKLMNOPQ1ST
```

This command will return the familiar access and secret key value pair used to programmatically access AWS;

```
[snowballEdge]
aws_access_key_id = ABCDEFGHIJKLMNOPQ1ST
aws_secret_access_key = ABC1DefgH2I3JkLmNOpqRS45tU6vWxYZab8DEF7g

```

Append the snowballEdge profile to your existing AWS profile. If you don't have one, follow instructions on how to configure AWS CLI for first time use. When appending, be sure to add the region = us-gov-west-1 to the end of the profile block.

Next you'll need to get a list of certificate ARNs and ultimately the certificate to be able to run AWS EC2 commands against the SBE.

```
./snowballEdge list-certificates

{
  "Certificates" : [ {
    "CertificateArn" : "arn:aws:snowball-device:::certificate/129d551c4b217037bbe93613d790dbf4",
    "SubjectAlternativeNames" : [ "10.1.100.210" ]
  } ]
}
```

Next copy the ARN and run;

```
./snowballEdge get-certificate --certificate-arn arn:aws:snowball-device:::certificate/129d551c4b217037bbe93613d790dbf4 > path/to/cert/cert_name.pem
```

With the certificate and keys in place you can now run EC2 commands with the --endpoint switch equal to https://(SBE IP):8243, and S3 commands with port redirection to 8443. As a note, if you are running multiple profiles, it will be necessary to run the AWS commands with the *--profile <profile_name>* switch.

```
aws ec2 describe-images --endpoint https://192.168.1.1:8243 --profile snowballEdge --ca-bundle path/to/your_cert.pem

aws s3 ls --profile snowballEdge --endpoint https://192.168.1.1:8443 --ca-bundle ca-bundle.pem
```

AWS SBE comes with two endpoints, one secure (https) and the other insecure (http). The secure endpoints (ports) are listed above for EC2 and S3 respectively, below are the insecure (http) ports

EC2: 8008

S3: 8080

If connectivity issues arise, troubleshooting steps are available at <https://docs.aws.amazon.com/snowball/latest/developer-guide/troubleshooting.html>

It's worth noting that on an event of a power loss that the statically assigned IP will be wiped and the SBE will enter into a locked state again.  From a security perspective this is great, from a development and potentially a disconnected operation perspective, this creates an inconvenience at the least.

## SBE Automation

There are several scripts written within ../edge_computing/automation/k8s/terraform/sbe/scripts. A separate README will be written for the various scripts and placed in the same path.  Much of the setup portion of this documentation has been written as a script to ease the setup and usage of a SBE.

### Terraform Setup

There are small variances necessary for terrafrom to be able to target the SBE versus your AWS account. Within the Terrafrom provider there are optional switches to further configure the provider and narrow the scope. In the case of leveraging Terraform for SBE we will specify the *custom service endpoint* (<https://www.terraform.io/docs/providers/aws/guides/custom-service-endpoints.html>)

e.g.

```
provider "aws" {
  region  = "us-gov-west-1"
  profile = "snowballEdge"
  endpoints {
    ec2      = "http://192.168.1.1:8008"
    s3       = "http://192.168.1.1:8080"
  }
}
```

It is also necessary to setup additional options if the remote state will be configured for the S3 bucket running on SBE;

```
terraform {
  #required_version = ">= 0.12"
  backend "s3" {
    endpoint = "http://192.168.1.1:8080"
    region = "us-gov-west-1" # Basically this gets ignored.
    profile = "snowballEdge"
    bucket = "antipode"
    key = "terrafrom.tfstate"
    force_path_style = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
  }
}
```

### AWS SBE Setup

The SBE is a physical device offered as part of the AWS service as a service. To procure a SBE, you must log into the AWS console and create a 'job' which ends in an order to ship a unit out. The SBE ships locked to prevent unwanted access and potential injection of malicious software in transit. Once received the unit must be unlocked. 

Unlocking the device is done via the snowball or snowball edge CLI client. There are CLI clients for Windoes, Mac, and Linux (link to page available from AWS console for the SBE job details). The linux documentation omits on important detail compared to the examples listed in AWS documentation, it wasn't clear or obvious that linux users must run the command as ./snowball or ./snowballEdge pending the device. The documentation can be found at <https://github.com/awsdocs/aws-snowball-developer-guide/blob/master/doc_source/common-get-start.md>

Once unlocked it is advisable to update the SBE and to set up a virtual IP on the device. Once the virtual IP is established, you'll see a json return of what the completed set up looks like,

```
{
  "VirtualNetworkInterface" : {
    "VirtualNetworkInterfaceArn" : "arn:aws:snowball-device:::interface/s.ni-83b73fa8650be15bc",
    "PhysicalNetworkInterfaceId" : "s.ni-8e47fb34c8e9d6383",
    "IpAddressAssignment" : "STATIC",
    "IpAddress" : "10.1.100.211",
    "Netmask" : "255.255.255.0",
    "DefaultGateway" : "10.1.100.1",
    "MacAddress" : "1e:fe:3f:30:19:5a"
  }
}
```

The virtual IP is useful where it is easier to click and drag files to the SBE versus via CLI

There are additional set up necessary to use the compute within the SBE that isn't well documented. The first of which is to retrieve the access key unique to the SBE (Windows and Mac should be able to omit ./ on all commands);  

```
./snowballEdge list-access-keys
```

The command should return something like this;

```
{
  "AccessKeyIds" : [ "ABCDEFGHIJKLMNOPQ1ST" ]
}
```

Copy the key ID and run;

```
./snowballEdge get-secret-access-key --access-key-id ABCDEFGHIJKLMNOPQ1ST
```

This command will return the familiar access and secret key value pair used to programmatically access AWS;

```
[snowballEdge]
aws_access_key_id = ABCDEFGHIJKLMNOPQ1ST
aws_secret_access_key = ABC1DefgH2I3JkLmNOpqRS45tU6vWxYZab8DEF7g

```

Append the snowballEdge profile to your existing AWS profile. If you don't have one, follow instructions on how to configure AWS CLI for first time use. When appending, be sure to add the region = us-gov-west-1 to the end of the profile block.

Next you'll need to get a list of certificate ARNs and ultimately the certificate to be able to run AWS EC2 commands against the SBE.

```
./snowballEdge list-certificates

{
  "Certificates" : [ {
    "CertificateArn" : "arn:aws:snowball-device:::certificate/129d551c4b217037bbe93613d790dbf4",
    "SubjectAlternativeNames" : [ "10.1.100.210" ]
  } ]
}
```

Next copy the ARN and run;

```
./snowballEdge get-certificate --certificate-arn arn:aws:snowball-device:::certificate/129d551c4b217037bbe93613d790dbf4 > path/to/cert/cert_name.pem
```

With the certificate and keys in place you can now run EC2 commands with the --endpoint switch equal to https://(SBE IP):8243

```
aws ec2 describe-images --endpoint https://192.168.1.1:8243 --profile snowballEdge --ca-bundle path/to/your_cert.pem

```



 