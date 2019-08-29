provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

terraform {
  required_version = "< 0.12.0"
}

data "vsphere_datacenter" "dc" {
  name = "mh1"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "cluster1/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "public"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 2
  memory   = 1024
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label = "disk0"
    size  = 20
  }
}

module "infra" {
  source = "../modules/infra"

  region             = "${var.region}"
  env_name           = "${var.env_name}"
  availability_zones = "${var.availability_zones}"
  vpc_cidr           = "${var.vpc_cidr}"
  internetless       = false

  hosted_zone = "${var.hosted_zone}"
  dns_suffix  = "${var.dns_suffix}"

  tags = "${local.actual_tags}"
}

module "certs" {
  source = "../modules/certs"

  subdomains = ["*.pks"]
  env_name   = "${var.env_name}"
  dns_suffix = "${var.dns_suffix}"

  ssl_cert           = "${var.ssl_cert}"
  ssl_private_key    = "${var.ssl_private_key}"
  ssl_ca_cert        = "${var.ssl_ca_cert}"
  ssl_ca_private_key = "${var.ssl_ca_private_key}"
}

module "pks" {
  source = "../modules/pks"

  env_name                = "${var.env_name}"
  region                  = "${var.region}"
  availability_zones      = "${var.availability_zones}"
  vpc_cidr                = "${var.vpc_cidr}"
  vpc_id                  = "${module.infra.vpc_id}"
  private_route_table_ids = "${module.infra.deployment_route_table_ids}"
  public_subnet_ids       = "${module.infra.public_subnet_ids}"

  zone_id    = "${module.infra.zone_id}"
  dns_suffix = "${var.dns_suffix}"

  tags = "${local.actual_tags}"
}
