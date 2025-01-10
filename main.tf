terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  endpoint = "https://pve.lan:8006"
  username = "root@pam"
  password = "samo8>LOASD"
  insecure = true

  ssh {
    agent = true
  }
}

resource "proxmox_virtual_environment_file" "talos_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path = "talos.img"
  }
}

locals {
  vms = {
    "talos-control" = {
      mem = 2048
      cores = 2
      disk = {
        image = proxmox_virtual_environment_file.talos_image.id
        size = 30
      }
    },
    "talos-worker" = {
      mem = 3072
      cores = 2
      disk = {
        image = proxmox_virtual_environment_file.talos_image.id
        size = 30
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "vms" {
    for_each = local.vms
    name      = each.key
    node_name = "pve"
    stop_on_destroy = true
    cpu {
      type = "host"
      cores = lookup(each.value, "cores", 1)
    }
    #vga {
    #  type = "none"
    #}
    memory {
      dedicated = lookup(each.value, "mem", 1024)
      floating  = lookup(each.value, "mem", 1024) # set equal to dedicated to enable ballooning
    }
    operating_system {
      type = "l26"
    }
    serial_device {}
    disk {
      datastore_id = "local-lvm"
      interface    = "virtio0"
      iothread     = true
      discard      = "on"
      file_id = each.value.disk.image
      size = each.value.disk.size
    }
    network_device {
      vlan_id = 2
      bridge = "vmbr0"
    }
	 agent {
	 	enabled = true
	 }
}

#resource "proxmox_virtual_environment_network_linux_bridge" "vmbr99" {
#  node_name = "pve"
#  name      = "vmbr99"
#  address = "99.88.99.99/16"
#  comment = "vmbr99 comment"
#  ports = [
#    "enp2s0"
#  ]
#}

