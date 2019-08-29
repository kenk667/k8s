# K8s GovCloud Deployment

This repo contains resources to pave AWS GovCloud for deploying K8s. The current architecture is designed to deploy a management, services, and tools VPC each with 3 subnets balanced against three AZs. 

If you want to pave the underlying infra, start by pulling this repo and CD to ~/k8s-govcloud/terraform/aws and 