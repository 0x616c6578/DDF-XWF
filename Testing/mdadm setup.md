# Testing Environment For mdadm

The following processes were used to create software RAID arrays with DDF metadata superblocks on virtual hard disks.


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
<br>

## Parity Layout Options
**RAID5/6 parity block**
| layout | description |translation |
| - | - | - |
| left-asymmetric (la) | | RLQ: `0`
| left-symmetric (ls) | _default_ | RLQ: `3`
| right-asymmetric (ra) |
| right-symmetric (rs) |
| parity-first | Cause RAID5 to use a RAID4-like layout |
| parity-last | Cause RAID5 to use a RAID4-like layout |
| ddf-zero-restart | DDF-compatible layout |
| ddf-N-restart | DDF-compatible layout |
| ddf-N-continue | DDF-compatible layout |

**RAID 5-6 intermediary blocks**
| layout | description | translation |
| - | - | - |
| left-symmetric-6
| right-symmetric-6
| left-asymmetric-6
| right-asymmetric-6
| parity-first-6

**RAID 10**
> The number is the number of copies of each datablock. 2 is normal, 3 can be useful. This number can be at most equal to the number of devices in the array. It does not need to divide evenly into that number (e.g. it is perfectly legal to have an 'n2' layout for an array with an odd number of devices). 

| layout | description | translation |
| - | - | - |
| n# | signals 'near' copies. Multiple copies of one data block are at similar offsets in different devices. |
| o# | signals 'offset' copies. Rather than the chunks being duplicated within a stripe, whole stripes are duplicated but are rotated by one device so duplicate blocks are on different devices. Thus subsequent copies of a block are in the next drive, and are one chunk further down. |
| f# | signals 'far' copies (multiple copies have very different offsets). |