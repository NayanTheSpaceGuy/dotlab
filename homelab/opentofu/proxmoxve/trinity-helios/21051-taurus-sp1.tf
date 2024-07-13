resource "proxmox_vm_qemu" "taurus-sp1" {

  # Basic VM information
  name        = "taurus-sp1"
  desc        = "Taurus Server Production 1"
  target_node = "trinity-helios"
  vmid        = 21051
  tags        = "taurus,server,production,docker"

  # VM template and OS settings
  clone      = "deb-bookworm-cloud"
  full_clone = true
  qemu_os    = "other"
  bios       = "seabios"

  # Hardware configuration
  # agent   = 1
  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 2048
  scsihw  = "virtio-scsi-pci"

  # Boot and startup settings
  onboot           = true
  startup          = ""
  automatic_reboot = false

  # Disk configuration
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-zfs"
          size    = "2G"
          format  = "raw"
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-zfs"
        }
      }
    }
  }

  # Network configuration
  network {
    bridge = "vmbr0"
    model  = "virtio"
    tag    = "9"
  }

  # Cloud-Init settings
  ipconfig0  = "ip=10.72.9.51/24,gw=10.72.9.1,ip6=dhcp"
  nameserver = "10.72.9.1"
  ciuser     = "ntsa"
  cipassword = var.general_ci_password

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      disks,
      vm_state
    ]
  }

  # Other settings
  define_connection_info = false

}
