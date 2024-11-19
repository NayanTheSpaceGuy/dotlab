# Trinity-Helios Infrastructure Automation Guide

## Requirements:

#### Physical Server (Trinity Helios)
  - A dedicated physical server or bare-metal machine.

#### Another Device (infinity)
  - A device to log in to the proxmox web ui. This device should also be connected to the tailnet.

#### Keys (Keep these ready, these keys/tokens already exist and if you don't have these, you are not authorized)
  - GitHub Personal Access Token to clone git repo with HTTPS.
  - SOPS Public and Private Key to decrypt files.

#### Network
  - IP ranges:
    - 10.27.9.0/24 with VLAN 99
    - 10.72.9.0/24 with VLAN 9
    - 10.81.9.0/24 with VLAN 11
  - LAN connection to switch's port with
    - untagged VLAN 99 (lan)
      *Note: This untagged VLAN has to be set tagged later in the process)*
    - tagged VLAN 9 (servers trusted)
    - tagged VLAN 11 (servers untrusted)

## Steps:

### 1. Install Proxmox VE on Trinity-Helios
#### 1.1 **Initial Installation**
  - Ensure BIOS Firmware is latest. If not upgrade it first.
  - Download the latest Proxmox VE ISO from the official website.
  - Create a bootable USB drive with Rufus or Balena Etcher.
  - Boot the physical server from the installation media. (Requires changing boot order in BIOS)
  - Accept the EULA.
  - Select the physical disk to install proxmox ve. And in the options set this:
    - Software ZFS with RAID (0 or 1) and zstd compression.
    - Leave some space for swap partition and a small reserve partition for flexibility.
    - Under advanced options select zstd for compression algorithm.
  - Select country of your choice.
  - Select the timezone: Asia/Kolkata.
  - Select keyboard layout as U.S. English.
  - Set new password.
  - Enter email to receive notifications from your proxmox ve server.
  - Select the correct NIC and enter the following values:
    - FQDN: trinity-helios.penguin-tegus.ts.net
    - IP Address: 10.27.9.200/24
    - Gateway: 10.27.9.1
    - DNS Server: 10.27.9.1
  - Confirm the summary and install.

#### 1.2 **Setup More Storage**
  - Access the Proxmox VE [web interface](https://10.27.9.200:8006) and login with root user and the password you just set.
  - Go to console/shell and format swap partition of 8GB for 16GB RAM (not strict) and swapon.
  - Format and mount the reserve partition of 40GB for 256GB drive at /mnt/reserve/btrfs-1 (not strict)
  - Mount a partition for backup with NFS if possible. (backup-infinity)

  - Keep 'local' dir for snippets, container templates and iso images at /var/lib/vz
  - Keep 'local-zfs' zfs for containers and disk images only.
  - Create 'reserve-btrfs-1' btrfs for snippets at /mnt/reserve/btrfs-1

#### 1.3 **Setup Misc**
  - Setup SMTP Notifications.

### 2. **Create Setup LXC (Automation supports only Debian distributions currently)**
  - Download the Debian Bookworm LXC template with Proxmox VE web interface.
  - Create New 'helios-setup-lxc' CT.
  - Select the Debian Bookworm LXC template, Static IPv4 and DHCP IPv6. Confirm and Create the LXC.
  - Start the LXC and login with root. (ProxmoxVE Web Interface Shell is preferred over SSH)
  - This Setup LXC is supposed to be deleted after the final installation step.
    You will be reminded to do so at that step, now continue.

### 3. **Infra Setup : Part One**
#### 3.1 **Install Necronux and run the infra setup : part one*
  - Once you have logged into the LXC,
    Run the following command to download and install necronux and run the part one setup:
    ```
    apt-get update && apt-get install -y wget && \
    wget https://github.com/NayanTheSpaceGuy/necronux/releases/latest/download/necronux-linux-x64 && \
    chmod +x ~/necronux-linux-x64 && \
    ./necronux-linux-x64 infra run --host=trinity-helios --extra-flag=part-one
    ```
  - Enter the GitHub Personal Access Token, when asked. (The input will be hidden for security reasons)
  - Enter the SOPS Public and Private Key line by line, when asked. (The input will be hidden for security reasons)
  - After the script gets completed successfully, reboot trinity-helios.
    *Note: The ProxmoxVE host now expects VLAN 99 to be tagged and hence won't be available to the network.*

#### 3.2 **Tagged VLAN**
  - As mentioned earlier, the untagged VLAN 99 on the switch's port needs to be set to tagged VLAN 99
    Change the untagged VLAN 99 on the switch's port to primary tagged VLAN 99
  - And now access the Proxmox VE web interface with the new [link](https://trinity-helios.penguin-tegus.ts.net:8006)
  - Also set VLAN tag 99 in the network settings of the helios-setup-lxc

### 4. **Infra Setup : Part Two**
#### 4.1 **Run the infra setup : part two**
  - Log into the helios-setup-lxc,
    Run the following command to run the part two setup:
    ```
    ./necronux-linux-x64 infra run --host=trinity-helios --extra-flag=part-two
    ```

### 5. **Backup VMs and LXCs**
  - Setup backup jobs with Proxmox VE web interface.
