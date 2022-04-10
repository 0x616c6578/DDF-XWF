# Reconstruction Options
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