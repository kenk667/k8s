# Packer

This repo contains Packer JSON files for building various AMIs for the edge computing project. Packer has a dependency on environmental variables for discovering things like AWS secrets and keys without hard coding them. In order to avoid relying on ENV_VARS as a necessary component, shell scripts are written to execute the packer jobs. The reason for shell scripts are that when they run it creates a sub shell and environmental variables defined within the script are ephemeral to the run time of the script, removing the need for any additional cleanup tasks.

Each packer run will create a local artifact that lists the AMI information and each script is set to run verbosely. Most of the shell scripts are written to place the created AMI ID into terrrafrom variables where needed and as such it's important to keep this repo where it is unless the scripting is refactored to account for the move. 

## Installing AWS CLI Tools

<https://aws.amazon.com/cli/>

### Linux Install

On MacOS, Windows and Linux OS:

The officially supported way of installing the tool is with `pip`:

```
pip install awscli
```

##### *OR use these alternative methods for MacOS and Windows:*

### MacOS

You can grab the tool with homebrew, although this is not officially supported by AWS.

```
brew update && brew install awscli
```

## Installing Packer

Download appropriate release from https://www.packer.io/downloads.html and place in $PATH of your OS.

To verify install, run

```
packer -v
```

## Future Iteration

There is a longer term plan to hook these scripts in to concourse with a python script that determines last run, user input for new image, etc. for some kind of logic to help ensure all images are updated as needed and that there aren't missing AMI variables within Terraform.