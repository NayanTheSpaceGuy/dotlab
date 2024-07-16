resource "proxmox_vm_qemu" "canismajor-np1" {

  # Basic VM information
  name        = "canismajor-np1"
  desc        = "Canis Major NAS Production 1"
  target_node = "trinity-helios"
  vmid        = 18005
  tags        = "nas,production"

  # VM template and OS settings
  clone      = "truenas-core"
  full_clone = true
  qemu_os    = "l26"
  bios       = "seabios"

  # Hardware configuration
  agent   = 1
  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 2048
  scsihw  = "virtio-scsi-pci"

  # Boot and startup settings
  onboot           = true
  boot             = "order=scsi0;ide2"
  startup          = "order=1,up=10"
  automatic_reboot = false

  # Disk configuration
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-zfs"
          size    = "16G"
          format  = "raw"
        }
      }
    }
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/TrueNAS-Core-13.iso"
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
