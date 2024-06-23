# Trinity-Helios Infrastructure Automation Guide

## Requirements:

#### Physical Server (Trinity Helios)
- A dedicated physical server or bare-metal machine.

#### SSH Client (Preferably linux personal desktop or android with termux)
- Another device with an SSH client installed.

#### Keys (Keep these ready, these keys/tokens already exist and if you don't have these, you are not authorized)
- GitHub Personal Access Token to clone git repo with HTTPS.
- SOPS Public and Private Key to decrypt files.

## Steps:

### 1. Install Proxmox VE on Trinity Helios
#### 1.1 **Initial Installation**
  - Ensure BIOS Firmware is latest. If not upgrade it first.
  - Download the latest Proxmox VE ISO from the official website.
  - Create a bootable USB drive with Rufus or Balena Etcher.
  - Boot the physical server from the installation media. (Requires changing boot order in BIOS)
  - Follow the on-screen instructions and set the following values to complete the Proxmox VE installation.
    - Static IP: 10.27.9.200
    - Hostname: Trinity-Helios
    - FQDN: helios.trinity.spacehlship.xyz
    - Timezone: Asia/Kolkata
    - Storage: Read next section.

#### 1.2 **Setup Storage**
  - Setup Software ZFS with RAID (0 or 1) and zstd compression.
  - Leave some space for swap partition and a small reserve partition for flexibility.
  - Access the Proxmox VE [web interface.](https://10.27.9.200:8006)
  - Format swap partition of 8GB for 16GB RAM (not strict) and swapon.
  - Format and mount the reserve partition of 40GB for 256GB drive. (not strict)
  - Create and configure storage pools (e.g., local disks, network storage, etc.) in datacenter section.
  - Mount a partition for backup with NFS if possible. (backup-infinity)
  - Create 'local-cttmpls' dir for container templates at /var/lib/vz/cttmpls
  - Create 'local-isos' dir for iso images at /var/lib/vz/isos
  - Create 'reserve-btrfs-1' btrfs for snippets at /mnt/reserve/btrfs-1
  - Keep 'local' dir for snippets at /var/lib/vz
  - Keep 'local-zfs' zfs for containers and disk images.

#### 1.3 **Setup Misc**
  - Setup SMTP Notifications.
  - Set Next free VMID range to 1001 in Datacenter > options.

#### 2. **Create Setup LXC (Auomation supports only Debian distributions currently)**
  - Download the Debian Bookworm LXC template with Proxmox VE web interface.
  - Create New 'helios-setup-lxc' CT.
  - Select the Debian Bookworm LXC template, Static IPv4 and DHCP IPv6. Confirm and Create the LXC.
  - Start the LXC and login with root. (Proxmox Web Interface Shell is preferred over SSH)
  - This Setup LXC is supposed to be deleted after the final installation step.
    You will be reminded to do so at that step, now continue.

#### 3. **Run the Helios-Setup Bash Script**
  - Once you have logged into the LXC,
    Run the following command to download and execute the helios-setup bash script:
    ```
    apt-get update && apt-get install -y wget && \
    wget https://raw.githubusercontent.com/NayanTheSpaceGuy/dotfiles-and-homelab/main/homelab/bash/setup-trinity-helios/run-in-helios-setup-lxc.sh && \
    chmod +x ~/run-in-helios-setup-lxc.sh && \
    ./run-in-helios-setup-lxc.sh
    ```
  - Enter the GitHub Personal Access Token, when asked. (The input will be hidden for security reasons)
  - Enter the SOPS Public and Private Key line by line, when asked. (The input will be hidden for security reasons)
  - After the script gets completed successfully, reboot trinity-helios.

#### 4. **Trigger Opentofu Workflow in GitLab CI**
  - Manually trigger the gitlab-mirror-and-ci workflow in the GitHub repo.

#### 8. **Backup VMs and LXCs**
  - Setup backup jobs with Proxmox VE web interface.
