# **K8s Automation** & Life Cycle Management

## **Automation Tech Stack**

These are the current stack used to configure and deploy

- Terraform
- Concourse
- Packer
- Bash
- Cloud-Init
- Rancher
- GoLang

## Kubernetes Life Cycle Management

Deploying and managing Kubernetes means not only managing a container run time, but an orchestrator, cluster, applications, and services such as databases and MQ. The default for Kubernetes is to be stateless, so if statefull data exists, there needs to be a data strategy to address this as well. When managing K8s you have to think about if you are managing at the cluster level or down to an application/container run time. There's different commands between cluster and run time and to add complexity, it's not obvious what context you maybe working in between cluster context and pod context. 

To ease some of these issues, tooling will be installed on management plane AMIs as part of the packer build. If you'd like to install those tools locally, the tools are:

- Docker.io
- kuebadm
- kubectl
- PS1 (K8s Context and Namespace shell prompt, https://github.com/jonmosco/kube-ps1)
- Popeye  (K8s cluster sanitizer, https://github.com/derailed/popeye)
- Stern (K8s multi pod log aggregation, https://github.com/wercker/stern)
- Helm (Used both for application deployment and K8s infra dependencies running as containers)
- RKE (Rancher Kubernetes Runtime, CLI)

There are other tooling that was evaluated but decided against:

- Kops (Requires ENV_VARS which makes distribution and scale difficult)
- KubeOne (Dependency on Go and found the app to be unstable)
- Digital Rebar Provision (Overly complex to setup and doesn't scale well)
- Kubespray (Reliance on Ansible and creates state conflict with Terraform)
- Conjure-up/Charmed Canonical (AWS version doesn't work at all)

## Tool Installation

Please refer to each tool project documentation for installation on your OS. For reference on installation on Linux, specifically Ubuntu 16.04, reference the Packer repo for ~/rancher_ami/rancher_install.sh