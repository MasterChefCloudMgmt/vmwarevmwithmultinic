provider "vsphere" {
  user           = "${var.user}"
  password       = "${var.password}"
  vsphere_server = "${var.host}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.region}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.cluster}/Resources"
 datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.templateName}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network2" {
  name          = "${var.network_interface2}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_network" "network1" {
  name          = "${var.network_interface1}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_disk" "myDisk" {
  size         = 30
  vmdk_path    = "${var.diskpath}"
  datacenter = "${data.vsphere_datacenter.dc.name}"
  datastore    = "${var.datastore}"
  type         = "thin"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.vmname}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 1
  memory   = 512
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type            = "${data.vsphere_virtual_machine.template.scsi_type}"
  folder               = "${var.region}/vm/${var.foldername}"  

  network_interface {
    network_id = "${data.vsphere_network.network1.id}"
  }
  network_interface {
    network_id = "${data.vsphere_network.network2.id}"
  }

wait_for_guest_net_timeout = 0
disk {
   #size ="${vsphere_virtual_disk.myDisk.size}"
    label="demodisk1"
    attach = true
    datastore_id     = "${data.vsphere_datastore.datastore.id}"
    path = "${vsphere_virtual_disk.myDisk.vmdk_path}"
    unit_number = 0
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  } 
}
