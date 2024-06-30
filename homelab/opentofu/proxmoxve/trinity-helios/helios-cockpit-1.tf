resource "proxmox_vm_qemu" "helios-cockpit-1" {
  name        = "helios-cockpit-1"
  desc        = "Helios Cockpit 1"
  agent       = 1
  target_node = "trinity-helios"
  qemu_os     = "other"   # default other
  bios        = "seabios" # default=ovmf

  define_connection_info = false

  # -- only important for full clone
  vmid       = 21001
  clone      = "deb-bookworm-cloud"
  full_clone = true
  # full_clone = false

  # -- boot process
  onboot           = true
  startup          = ""
  automatic_reboot = false # refuse auto-reboot when changing a setting

  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 2048

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }

  scsihw = "virtio-scsi-pci" # default virtio-scsi-pci

  # disk {
  #     storage  = "pv1"
  #     type     = "virtio"
  #     size     = "40G"
  #     iothread = 1
  # }

  # -- lifecycle
  lifecycle {
    ignore_changes = [
      vm_state
    ]
  }

  # Cloud Init Settings
  ipconfig0  = "ip=10.27.9.98/24,gw=10.20.0.1,ip6=dhcp"
  nameserver = "10.27.9.1"
  ciuser     = "ntsa"
}
