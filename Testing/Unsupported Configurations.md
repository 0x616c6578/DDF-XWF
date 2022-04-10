# Unsupported DDF RAID configurations

Numbered cells refer to data _Strips_
**Integrated Adjacent Stripe Mirroring (N*2)**
| | | | | |
|-|-|-|-|-|
| Stripe 0 | 1 | ~~1~~ | 2 | ~~2~~ |
| Stripe 1 | 3 | ~~3~~ | 4 | ~~4~~ |
| Stripe 2 | 5 | ~~5~~ | 6 | ~~6~~ |

**Integrated Adjacent Stripe Mirroring (N*2-1)**
| | | | | | |
|-|-|-|-|-|-|
| Stripe 0 | 1 | ~~1~~ | 2 | ~~2~~ | 3 |
| Stripe 1 | ~~3~~ | 4 | ~~4~~ | 5 | ~~5~~ |
| Stripe 2 | 6 | ~~6~~ | 7 | ~~7~~ | 8 |

**Integrated Offset Stripe Mirroring**
| | | | | | |
|-|-|-|-|-|-|
| Stripe 0 | 1 | 2 | 3 | 4 | 5 |
| Stripe 1 | ~~5~~ | ~~1~~ | ~~2~~ | ~~3~~ | ~~4~~ |
| Stripe 2 | 6 | 7 | 8 | 9 | 10 |
| Stripe 3 | ~~10~~ | ~~6~~ | ~~7~~ | ~~8~~ | ~~9~~ |

## Sections
| Signature Name | Signature Value | Offset Name |
|-|-|-|
| DDF_Header | `0xDE11DE11` |
| Controller_Data | `0xAD111111` |
| Physical_Disk_Records | `0x22222222` |
| Physical_Disk_Data | `0x33333333` |
| Virtual_Disk_Records | `0xDDDDDDDD` |
| VD_Configuration_Record | `0xEEEEEEEE` |
| Spare_Assignment_Record | `0x55555555` |
| VU_Configuration_Record | `0x88888888` |
| Vendor_Specific_Log | `0x01DBEEF0` |
| Bad_Block_Management_Log | `0xABADB10C` |

## GUIDS
| GUID | Description | 
| :-: | :- | 
| Controller | The Controller GUID MUST be an ASCII string built by combining the T10 Vendor ID and the last 16 characters from the controller serial number.<br>If the T10 Vendor ID is less than eight characters or the controller serial number is less than 16 characters, the fields MUST be padded by ‘space’ (0x20) to achieve the required length. Padding MUST be placed between the vendor name and serial number.<br>NOTE: If there is no serial number defined for the controller, then the 16 byte serial number field MUST be built by concatenating an 8-byte ASCII representation of a 4-byte timestamp (bytes 8-15) and an 8-byte ASCII representation of a 4-byte random number (bytes 16-23). This number SHOULD be created on the first configuration and stored in the controller’s non-volatile memory. This field SHOULD NOT be user modifiable so that it remains constant for the controller’s life from user’s perspective.
| Physical Disk | For physical disks that are accessed using SCSI commands (e.g., Parallel SCSI, Serial Attached SCSI, and Fibre Channel physical disks), the PD GUID MUST be built by combining the T10 Vendor ID of the disk vendor with the identifier returned by INQUIRY page 83h (Association=0 Identifier Type=1h, 2h, 3h or 8h) or the serial number returned in EVPD page 80h, or with the serial number returned in VPD page 89h (for SATA disks). If the identifier returned by INQUIRY page 83 or the disk serial number in EVPD page 80h is longer than 16 bytes, then the 16 least significant bytes MUST be used and the higher bytes discarded. If the serial number returned by EVPD page 80h is ‘left justified’ with spaces in the least significant bytes, the serial number MUST be ‘right justified’ before discarding the higher bytes and using the 16 least significant bytes. If VPD page 89h is used to return the SATA disk serial number, a ‘space’ (0x20) MUST separate the string “HDD” from the 20 byte disk serial number. If the vendor name is less than eight characters or the disk serial number/identifier is less than 16 characters, the fields MUST be padded by ‘space’ (0x20) to achieve the required length. Padding MUST be placed between the vendor name and serial number/identifier. The following is an example of a PD_GUID for a SCSI disk, where the serial number/identifier is “5G45B673” and the T10 Vendor ID is “HDD.”<br> When a serial number is not available for physical disks accessed using SCSI commands or the PD_GUID generated is not unique among the disks accessed by the controller, the controller MUST generate a forced serial number by concatenating an eight byte current date in “yyyymmdd” ASCII format and an eight byte hexadecimal ASCII representation of a four byte random number. The GUID generated using this serial number is considered a forced PD GUID and the Forced_PD_GUID_Flag in the PD_Type field of the Physical Disk Entry (Section 5.7.1) for the physical disk MUST be set. In addition, the Forced_PD_GUID_Flag in the disk’s Physical_Disk_Data section MUST also be set (Section 5.10). The controller MUST guarantee that a Forced PD GUID is unique among the drives accessed by the controller. The following is an example of a forced PD GUID, where the date is February 1, 2004, the eight byte hexadecimal ASCII representation of the four byte random number is “AABBCCDD” and the disk’s T10 Vendor ID is “HDD.”<br> For ATA or SATA physical disks, PD_GUID MUST be built by combining the three character ASCII string “ATA”, with the 20-byte disk serial number as reported in response to ATA Identify Device command (bytes 20-39). A ‘space’ (0x20) MUST separate the string “ATA” from the disk serial number. The following is an example of PD_GUID for an ATA disk where the serial number is “BB583GX3389103443379.”<br> When a serial number is not available for ATA or SATA physical disks, the controller MUST generate one by concatenating an eight character current date in “yyyymmdd” ASCII format and a twelve byte hexadecimal ASCII representation of a six byte random number. The GUID generated using this serial number is considered a forced PD_GUID and the Force_PD_GUID_Flag in the PD_Type field of the Physical Disk Entry (Section 5.7.1) for the physical disk MUST be set. In addition, the Forced_PD_GUID_Flag in the disk’s Physical_Disk_Data section MUST also be set (Section 5.10). The following is an example of a forced PD GUID, where the date is February 1, 2004 and the twelve byte hexadecimal ASCII representation of the six byte random number is “AABBCCDDEEFF”
| Virtual Disk | The VD GUID MUST be built by concatenating the creating controller’s T10 Vendor ID with a 16 byte unique identifier. The 16 byte identifier MAY be created by concatenating the Controller_Type field from Controller Data (Section 5.6), a 4-byte timestamp, and a 4-byte random number. Using this method, the VD_GUID provides data about age and the creating controller type. The following is an example of a VD_GUID with a vendor ID of “VENDORID”, a Controller_Type field of “AAAAAAAA”, a time stamp of “BBBB”, and a random number of “CCCC.”<br> Alternatively, the unique identifier MAY be created by the controller using a vendor specific method. If this method is used, the controller MUST guarantee that the identifier is unique for all virtual disks in the system.
| DDF Header | The DDF Header GUID MUST be built by concatenating the creating controller’s T10 Vendor ID, the Controller_Type field from Controller Data (Section 5.6), a 4-byte timestamp, and a 4-byte random number. The DDF_GUID provides data about age and the creating controller type. The following is an example of a DDF_GUID with a vendor ID of “VENDORID”, a Controller_Type field of “AAAAAAAA”, a time stamp of “BBBB”, and a random number of “CCCC.” |