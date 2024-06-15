# Trinity-Helios Infrastructure Automation Guide

## Requirements:

#### Physical Server (Trinity Helios)
- A dedicated physical server or bare-metal machine.

#### SSH Client (Preferably linux personal desktop or android with termux)
- Another device with an SSH client installed.
- This device must have the appropriate GitHub SSH keys. (This is usually done when authenticating with GitHub CLI)

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
  - Mount a partition for backup with NFS if possible.

#### 2. **Create Setup VM (Auomation supports only Debian distributions currently)**
  - Download the Debian netinst ISO with Proxmox VE web interface.
  - Create New 'Setup' VM.
  - Select the Debian ISO as the installation media
  - Start the VM and follow the on-screen instructions to install Debian.
  - This Setup VM is supposed to be deleted after the final installation step. You will be reminded to do so at that step, now continue.

#### 3. **Run the Helios-Setup Bash Script**
  - Once the Setup VM is set up, SSH into the VM. (SSH is required for the next steps)
  - Run the following command to download and execute the helios-setup bash script:

  ```
  curl -O ~/helios-setup.sh https://raw.githubusercontent.com/NayanTheSpaceGuy/dotfiles-and-homelab/main/homelab/bash/trinity-helios-setup/helios-setup.sh && \
  chmod +x ~/helios-setup.sh && \
  .~/helios-setup.sh
  ```

#### 4. **Trigger Opentofu Workflow in GitLab CI**A
  - Manually trigger the gitlab-mirror-and-ci workflow in the GitHub repo.
