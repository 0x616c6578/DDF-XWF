# Reconstruction Guide
_Using DDF Metadata to reconstruct a RAID array using X-Ways Forensics_

<br>

| Step | Details | Screenshot |
|:-: | - | - |
| **1.** |  Create a new case in XWF and add all disk images. | ![](./Screenshots/usage_1.png)
| **2.** | Select the first evidence object. In the **View** Menu select **Template Manager..**. (Alt+F12). Select the **DDF - Reconstruction** template. | ![](./Screenshots/usage_2.png) |
| **3.** | **Apply** the template (Enter).  Note the Note the details in the _Configuration Records_ and _Physical Disk Data_ section: <br> - The *VD GUID* may be used to uniquely identify a virtual disk.<br> - The first group (*Primary_Element_Count* through to *Secondary_RAID_Level*) are the reconstruction options, as per the tables above.<br> - The second group (*PD_Reference ##*) shows the order of PDs in the VD which the current disk is a member of.<br> - The third group shows the PD reference for the current disk.| ![](./Screenshots/usage_3.png) |
| **4.** | Repeat steps 2-3 for the remaining evidence objects (disks).  You may ignore most fields for subsequent disks in the same VD (as identified by the VD Guid) and just record the PD Reference. | _DIsk-1_: `D0 C3 FA 79`<br>_Disk-2_: `B1 54 C9 50`<br>_Disk-3_: `2B 85 99 E5`<br>_Disk-4_: `E9 1B D7 C6`<br>_Disk-5_: `50 50 91 E2`.
| **5.** | In the **Specialist** menu select **Reconstruct RAID System**. Enter components and options identified in the preceding steps.<br> - Select the RAID level/type based on the RLQ and PRL, translated in the table below.<br> - Take the strip size in sectors from the *Strip_Size* field extracted previously. *Note: X-Ways specifies this in sectors and the formula provided (`(2^n)*512`) calculates the strip size in _bytes_.  The **DDF-Reconstruction** template used here assumes a 512-byte sector, and if you made it this far the assumption is proven accurate.  The true formula is therefore `2^n`* | ![](./Screenshots/usage_4.png) |
| **6.** | Press **OK** to complete the reconstruction.  This will add a new item to the tab bar titled (in this example) _RAID 5: Disk-1 + Disk-4 + Disk-2 + Disk-3 + Disk-5_.  Right-Click this and add it to the case.  If you have completed all steps correctly, you will see the volume and data contained in the original volume(s) located on the RAID array. | ![](./Screenshots/usage_5.png)

<br>

## Translation Table
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
| `15` | `00` | RAID-5E Rotating Parity 0 with Data Restart | Level 5: forward parity | - Identical to PRL `05` RLQ `00` in used stripes.  Testing is needed to confirm whether X-Ways can reconstruct.<br> - Can be reconstructed with 1 missing disk.
| `15` | `02` | RAID-5E Rotating Parity N with Data Restart | Level 5: backward parity | - Identical to PRL `05` RLQ `02` in used stripes.  Testing is needed to confirm whether X-Ways can reconstruct.<br> - Can be reconstructed with 1 missing disk.
| `15` | `03` | RAID-5E Rotating Parity N with Data Continuation | Level 5: backward dynamic | - Identical to PRL `05` RLQ `03` in used stripes.  Testing is needed to confirm whether X-Ways can reconstruct.<br> - Can be reconstructed with 1 missing disk.
| `25` | `00` | RAID-5EE Rotating Parity 0 with Data Restart | Level 5EE: forward parity | - The diagram in the X-Ways manual shows a default parity offset of 2 components. This needs to be confirmed.<br> - Can be reconstructed with 1 missing disk. |
| `25` | `02` | RAID-5EE Rotating Parity N with Data Restart | Level 5EE: backward parity | - X-Ways doesn't provide an option for a parity offset with this level. <br> - Can be reconstructed with 1 missing disk. |
| `25` | `03` | RAID-5EE Rotating Parity N with Data Continuation | | _Cannot be reconstructed._ |
| `11` | `00` | Integrated Adjacent Stripe Mirroring | Level 0<sup>*</sup> | - Reconstruct as you would normally with a spanned VD (RAID-0), discarding every second disk. <br> - <sup>*</sup>This will only work for an even number of disks|
| `11` | `01` | Integrated Offset Stripe Mirroring |  | _Cannot be reconstructed._ |
| `06` | `01` | RAID 6 Rotating Parity 0 with Data Restart | Level 6: forward parity | - Can be reconstructed with 2 missing disks. |
| `06` | `02` | RAID 6 Rotating Parity N with Data Restart | Level 6: backward parity | - Can be reconstructed with 2 missing disks. |
| `06` | `03` | RAID 6 Rotating Parity N with Data Continuation | Level 6: backward dynamic| - Can be reconstructed with 2 missing disks. |