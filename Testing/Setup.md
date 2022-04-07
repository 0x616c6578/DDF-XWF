# Testing Environment For mdadm

The following processes were used to create RAID arrays with DDF metadata superblocks on virtual hard disks.


## Host Environment
> Windows 11, Hyper-V as hypervisor.  A VM was created titled "RAID_Testing".
1. Create VHDs
   ```powershell
   (1..5)|%{New-VHD ".\Group1\Disk-$_.vhd" 128MB -Dynamic}
   ```
2. Add VHDs to the VM
   ```powershell
   (1..5)|%{Add-VMHardDiskDrive -VMName "RAID_Testing" -Path ".\Group1\Disk-$_.vhd"}
   ```

<br>

## Guest Environment
> Default Ubuntu 21.04 LTS minimal install
> 
**Setup**

1.  Update repositories
    ```bash
    sudo apt-get update
    ```
2.  Install packages
    ```bash
    sudo apt-get install mdadm xfsprogs
    ```

**Array Creation**
1. Identify the devices to be used for the array.  They will all be 128MB.
    ```bash
    lsblk
    ```
2.  Create a container for the external metadata
    ```bash
    sudo mdadm --create --verbose /dev/md/ddf /dev/sd[a-e] --raid-devices 5 --metadata=ddf
    ```
3. Create a volume within the container
    ```bash
    sudo mdadm --create --verbose /dev/md/vol1 /dev/md/ddf --raid-devices 5 --level 5 --layout ddf-zero-restart
    ```
    > **Note:** The `--layout` parameter may be altered in accordance with the _layout options_ discussed in the next section. It can alsy be omitted for left-symmetric parity.

**Adding Data**
1. Build a filesystem on the RAID device
   ```bash
   sudo mkfs -t xfs -d sunit=1024 -d swidth=4096 /dev/md/vol1
   ```
2. Mount the filesystem
   ```bash
   sudo mkdir /mnt/raid
   sudo mount /dev/md/vol1 /mnt/raid
    ```
3. Add sample data
    ```bash
    sudo wget "https://www.snia.org/sites/default/files/SNIA-DDFv1.2.pdf" -o "/mnt/raid/SNIA-DDFv1.2.pdf"
    ```