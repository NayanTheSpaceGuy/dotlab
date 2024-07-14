resource "proxmox_vm_qemu" "canismajor-np1" {

  # Basic VM information
  name        = "canismajor-np1"
  desc        = "Canis Major NAS Production 1"
  target_node = "trinity-helios"
  vmid        = 11005
  tags        = "nas,production"

  # VM template and OS settings
  full_clone = false
  qemu_os    = "l26"

  # Hardware configuration
  agent   = 1
  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 2048
  scsihw  = "virtio-scsi-pci"

  # Boot and startup settings
  onboot           = true
  startup          = "order=1,up=10"
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
  ipconfig0  = "ip=10.72.9.5/24,gw=10.72.9.1,ip6=dhcp"
  nameserver = "10.72.9.1"
  ciuser     = "ntsa"
  cipassword = var.GENERAL_CI_PASSWORD
  sshkeys    = var.PUBLIC_SSH_KEYS

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
