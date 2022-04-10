# DDF Metadata Analysis in X-Ways Forensics
This repository provides resources necessary to reconstruct RAID arrays in X-Ways Forensics using the DDF Metadata (RAID superblock), utilised by modern hardware RAID controllers.

## Table of contents
  - [Background](#background)
    - [Terminology](#terminology)
  - [Templates](#templates)
  - [Reconstruction Options](#reconstruction-options)
  - [Usage](#usage)
    - [Reconstruction](#reconstruction)
  - [ToDo](#todo)

<br>

## Background
From the [Storage Networking Industry Association (SNIA)](https://www.snia.org/tech_activities/standards/curr_standards/ddf):
> The Common RAID Disk Data Format specification defines a standard data structure describing how data is formatted across the disks in a RAID group. The Disk Data Format (DDF) structure allows a basic level of interoperability between different suppliers of RAID technology.

In practical terms, the ddf structure is metadata residing in the last addressable blocks of a disk. This metadata contains details about the RAID controller with which the disk was last used, as well as other connected disks.  These details may be used to reconstruct arrays and identify when a partilcuar disk or array was created.


### Terminology
The [DDF Specification](https://www.snia.org/sites/default/files/SNIA-DDFv1.2.pdf) makes use of the following terminology:
- **Virtual Disk (VD)**:  A virtual disk is the object presented to the host level for data storage.  At least one physical disk is associated with a VD.
- **Basic Virtual Disk (BVD)**:  A basic virtual disk is a VD configured using only non-hybrid RAID levels like RAID-0, RAID5, or RAID5E. Its elements are physical disks.
- **Secondary Virtual Disk (SVD)**:  A secondary virtual disk is a VD configured using hybrid RAID levels like RAID10 or RAID50. Its elements are BVDs.
- **Primary RAID Level (PRL)**:  
    | Name          | PRL Byte | Description                                                                                            |
    | ------------- | -------- | ------------------------------------------------------------------------------------------------------ |
    | RAID-0        | `00`     | Striped array with no parity                                                                           |
    | RAID-1        | `01`     | Mirrored array                                                                                         |
    | RAID-3        | `03`     | Striped array with typically non-rotating parity, optimized for long, single-threaded transfers        |
    | RAID-4        | `04`     | Striped array with typically non-rotating parity, optimized for short,multi-threaded transfers         |
    | RAID-5        | `05`     | Striped array with typically rotating parity, optimized for short, multi-threaded transfers            |
    | RAID-6        | `06`     | Similar to RAID-5, but with dual rotating parity physical disks, tolerating two physical disk failures |
    | RAID-1E       | `11`     | >2 disk RAID-1, similar to RAID-10 but with striping integrated into array                             |
    | Single Disk   | `0F`     | Single, non-arrayed disk                                                                               |
    | Concatenation | `1F`     | Physical disks combined head to tail                                                                   |
    | RAID-5E       | `15`     | RAID-5 with hot space at end of array                                                                  |
    | RAID-5EE      | `25`     | RAID-5 with hot space integrated into array                                                            |
- **RAID Level Qualifier (RLQ)**:
- **Secondary RAID Level (SRL)**:
    | Name         | SRL Byte | Description                                                                             |
    | ------------ | -------- | --------------------------------------------------------------------------------------- |
    | Striped      | `00`     | Data is striped across Basic VDs. First strip stored on first BVD and next on next BVD. |
    | Mirrored     | `01`     | Data is mirrored across Basic VDs.                                                      |
    | Concatenated | `02`     | Basic VDs combined head to tail.                                                        |
    | Spanned      | `03`     | A combination of stripping and concatenations involving Basic VDs of different sizes.   |
- **Section Context**: Context refers to the scope of information contained within a section. Sections with a _Global_ context will be identical for all PDs connected to the same controller at the same time. Sections with a _Local_ context will be specific to a PD or VD(s) which it is assigned to.
    | Section                    | Context | Description                                                                                                  |
    | -------------------------- | ------- | ------------------------------------------------------------------------------------------------------------ |
    | DDF Header                 | Global  |                                                                                                              |
    | Controller Data            | Global  | Provides details about the last controller that operated on an attached RAID configuration.                  |
    | Physical Disk Recrods      | Global  | Lists all configured PDs attached to a controller.                                                           |
    | Virtual Disk Records       | Global  | Lists all configured VDs tracked by the DDF structure.                                                       |
    | Configuration Records      | Local   | Lists the configuration of VD(s) to which the current PD is assigned, or contains a spare assignment record. |
    | Physical Disk Data         | Local   | Stores the PD GUID and Reference number.                                                                     |
    > **Note**: several _OPTIONAL_ sections have been omitted.  They are not consistent enough to have value.

Global section structures are particularly useful if you have a subset of disks from a server and want details on other PDs and VDs which may have been used with the same RAID controller. Local section structures  are necessary to reconstruct arrays; the PRL, RLQ, SRL, strip size, and PD reference sequence may be translated into options for the _Reconstruct RAID System_ X-Ways feature in X-Ways Forensics.
<br>

## Templates
There are four templates available within this repository, each with a different use case:

1. [`DDF - Reconstruction`](./Templates/DDF%20-%20Reconstruction.tpl):  This extracts the bare-minimum details required to reconstruct an array from the (local) virtual disk settings identified on a given disk.  It will display the virtual disk (array) settings such as raid level, parity, etc., as well as the order of physical disks within the array.  It will also extract the physical disk reference for the current disk.
2. `DDF - Global`
3. `DDF - Local`
4. [`DDF - All`](./Templates/DDF%20-%20All.tpl): This extracts all sections from the DDF metadata and presents them in a single window.

<br>

## Reconstruction Options
These options were derived from **Section 4** of the [DDF Specification](https://www.snia.org/sites/default/files/SNIA-DDFv1.2_with_Errata_A_Applied.pdf) and **Section 10.15 Reconstructing RAID Systems** from the [X-Ways manual](http://www.x-ways.net/winhex/manual.pdf).  Use this table as a reference to convert the DDF metadata field values to options within the X-Ways raid reconstruction window.  
> Note: RAID configurations defined in DDF metadata are _universal_ and not implementation (manufacturer) dependent; you can disregard specific manufacturer text within the _Reconstruct RAID System_ window e.g. Adaptec, AMI, HP, etc.

| PRL  | RLQ  | DDF RAID Type | X-Ways  RAID Level | Details |
| - | - | - | - | -|
| `00` | `00` | RAID-0 Simple Striping | Level 0 |
| `01` | `00` | RAID-1 Simple Mirroring | _Not required_ | - No reconstruction is necessary; VD blocks are mirrored to both PDs. |
| `01` | `01` | RAID-1 Multi Mirroring | _Not required_ | - No reconstruction is necessary; VD blocks are mirrored to all PDs. |
| `03` | `00` | RAID-3 Non-Roating Parity 0 | | - Bit level stripping theoretically makes this impossible to  reconstruct in XWF but testing will be needed to confirm whether it can be done with reduced strip sizes. |
| `03` | `01` | RAID-3 Non-Rotating Parity N | |- Bit level stripping theoretically makes this impossible to  reconstruct in XWF but testing will be needed to confirm whether it can be done with reduced strip sizes. |
| `04` | `00` | RAID-4 Non-Rotating Parity 0 | Level 0| - VD Blocks are striped across _n-1_ disks, with the first being parity.<br> - Discard the parity disk to reconstruct as a RAID-0.<br> - No fault tolerance: all (non-parity) PDs are required. |
| `04` | `01` | RAID-4 Non-Rotating Parity N | Level 0| - VD Blocks are striped across _n-1_ disks, with one being parity.<br> - Discard the parity disk to reconstruct as a RAID-0.<br> - No fault tolerance: all (non-parity) PDs are required. |
| `05` | `00` | RAID-5 Rotating Parity 0 with Data Restart | Level 5: forward parity | - Can be reconstructed with 1 missing disk |
| `05` | `02` | RAID-5 Rotating Parity N with Data Restart | Level 5: backward parity | - Can be reconstructed with 1 missing disk |
| `05` | `03` | RAID-5 Rotating Parity N with Data Continuation | Level 5: backward dynamic | - Can be reconstructed with 1 missing disk |
| `06` | `01` | RAID 6 Rotating Parity 0 with Data Restart | Level 6: forward parity | - Can be reconstructed with 2 missing disks. |
| `06` | `02` | RAID 6 Rotating Parity N with Data Restart | Level 6: backward parity | - Can be reconstructed with 2 missing disks. |
| `06` | `03` | RAID 6 Rotating Parity N with Data Continuation | Level 6: backward dynamic| - Can be reconstructed with 2 missing disks. |
| `07` | `00` | MDF RAID Rotating Parity 0 with Data Restart | | - Testing needed.<br> - Identical to RAID 6 with 2 parity disks |
| `07` | `02` | MDF RAID Rotating Parity N with Data Restart | | - Testing needed.<br> - Identical to RAID 6 with 2 parity disks |
| `07` | `03` | MDF RAID Rotating Parity N with Data Continuation | | - Testing needed.<br> - Identical to RAID 6 with 2 parity disks |
| `0F` | `00` | Single Disk | _Not required_ | - No reconstruction is necessary; the PD contains all blocks for the VD. |
| `11` | `00` | RAID-1E Integrated Adjacent Stripe Mirroring | Level 0<sup>*</sup> | - Reconstruct as you would normally with a spanned VD (RAID-0), discarding every second disk. <br> - <sup>*</sup>This will only work for an even number of disks|
| `11` | `01` | RAID-1E Integrated Offset Stripe Mirroring |  | _Cannot be reconstructed._ |
| `15` | `00` | RAID-5E Rotating Parity 0 with Data Restart | Level 5: forward parity | - Identical to PRL `05` RLQ `00` in used stripes.  Testing is needed to confirm whether X-Ways can reconstruct.<br> - Can be reconstructed with 1 missing disk.
| `15` | `02` | RAID-5E Rotating Parity N with Data Restart | Level 5: backward parity | - Identical to PRL `05` RLQ `02` in used stripes.  Testing is needed to confirm whether X-Ways can reconstruct.<br> - Can be reconstructed with 1 missing disk.
| `15` | `03` | RAID-5E Rotating Parity N with Data Continuation | Level 5: backward dynamic | - Identical to PRL `05` RLQ `03` in used stripes.  Testing is needed to confirm whether X-Ways can reconstruct.<br> - Can be reconstructed with 1 missing disk.
| `1F` | `00` | Concatenation | JBOD/Linear | - Testing required. There is no associated diagram in the DDF specification.
| `25` | `00` | RAID-5EE Rotating Parity 0 with Data Restart | Level 5EE: forward parity | - The diagram in the X-Ways manual shows a default parity offset of 2 components. This needs to be confirmed.<br> - Can be reconstructed with 1 missing disk. |
| `25` | `02` | RAID-5EE Rotating Parity N with Data Restart | Level 5EE: backward parity | - X-Ways doesn't provide an option for a parity offset with this level. <br> - Can be reconstructed with 1 missing disk. |
| `25` | `03` | RAID-5EE Rotating Parity N with Data Continuation | | _Cannot be reconstructed._ |
| `35` | `00` | RAID-5 Rotating Parity 0 after R Stripes with Data Restart | | _Cannot be reconstructed._ |
| `35` | `02` | RAID-5 Rotating Parity N after R Stripes with Data Restart | | _Cannot be reconstructed._ |
| `35` | `03` | RAID-5 Rotating Parity N after R Stripes with Data Continuation | | _Cannot be reconstructed._ |



<br>

## Usage
The usage instructions below will assume you have disk images for the devices connected to the raid controller.  If you have not yet imaged a device, but have terminal access you can identify whether a device has a DDF metadata superblock with the following command:
```bash
sudo xxd -s -512 /dev/sdX
```
This shows a hexdump of the last 512 bytes of a device.  If it contains a DDF metadata superblock anchor the first bytes of this dump will be `de11 de11`.

### Reconstruction
_A [standalone guide](Reconstruction%20Guide.md) has also been created for this process._
1. Create a new case in XWF and add all disk images.
2. Select the first evidence object. In the **View** Menu select **Template Manager..**. (Alt+F12). Select the **DDF - Reconstruction** template.
3. **Apply** the template (Enter).  Note the Note the details in the _Configuration Records_ and _Physical Disk Data_ section:
   1. The *VD GUID* may be used to uniquely identify a virtual disk.
   2. The first group (*Primary_Element_Count* through to *Secondary_RAID_Level*) are the reconstruction options, as per the tables above.
   3. The second group (*PD_Reference ##*) shows the order of PDs in the VD which the current disk is a member of.
   4. The third group shows the PD reference for the current disk.
  
    ![](./Screenshots/usage_3.png)
4. Repeat steps 2-3 for the remaining evidence objects (disks).  You may ignore most fields for subsequent disks in the same VD (as identified by the VD Guid) and just record the PD Reference. 
5. In the **Specialist** menu select **Reconstruct RAID System**. Enter components and options identified in the preceding steps.
   1. Select the RAID level/type based on the RLQ and PRL, translated in the _Reconstruction Options_ table above.
   2. Take the strip size in sectors from the *Strip_Size* field extracted previously. 
      > **Note:** X-Ways specifies this in sectors and the formula provided (`(2^n)*512`) calculates the strip size in _bytes_.  The *DDF-Reconstruction* template used here assumes a 512-byte sector, and if you made it this far the assumption is proven accurate.  The true formula is therefore `2^n`
6. Press **OK** to complete the reconstruction.  This will add a new item to the tab bar titled (in this example) _RAID 5: Disk-1 + Disk-4 + Disk-2 + Disk-3 + Disk-5_.  Right-Click this and add it to the case.  If you have completed all steps correctly, you will see the volume and data contained in the original volume(s) located on the RAID array.

### Other Templates
Load the relevant evidence objects (disks) and apple the template, as specified in Step 2 of the reconstruction usage guide.  Some fields will have an asterisk (*) suffix; this indicates that there is additional documentation for the interpretation of the field value, available in the [DDF Fields.md documentation](./Documentation/DDF%20Fields.md).

<br>

## ToDo
1. Create additional [templates](./Templates/):
   1. Global section context
   2. Local section context
   3. ~~All metadata~~
2. Test additional [mdadm](./Testing/mdadm%20setup.md) parity layouts to confirm the reconstruction options table:
   1. right-asymmetric
   2. right-symmetric
   3. parity-first
   4. parity-last
   5. ddf-zero-restart
   6. ddf-N-restart
   7. ddf-N-continue
   8. RAID 5-6 intermediary blocks
   9. RAID 10
3. Test additional (hardware) RAID [controllers](./Testing/Controllers.md)