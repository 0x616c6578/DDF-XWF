template "DDF - All"
description "DDF metadata superblock data"
applies_to disk
sector-aligned
read-only
big-endian
fixed_start -512
requires 0 "DE11DE11"

begin
    section "DDF Header"
        hex 4           "Signature"
        move 4           // CRC
        string 8        "T10 Vendor ID"
        hex 2           "Vendor ID"
        hex 2           "Device ID"
        hex 2           "Sub Vendor ID"
        hex 2           "Sub DeviceID"
        int32           "Header Timestamp (GPSTime)"
        move 4          // Random number
        string 8        "DDF_rev*"
        int32           "Sequence_Number*"
        int32           "Last Updated (GPSTime)*"
        hex 1           "Open_Flag"
        hex 1           "Foreign_Flag*"
        hex 1           "Disk_Grouping"
        move 13         // Reserved
        move 32         // Header_Ext (reserved)
        int64           "Primary_Header_LBA"
        int64           "Secondary_Header_LBA"
        move 1          // Header_Type
        move 3          // Reserved
        move 4           // Workspace_Length
        int64           "Workspace_LBA"
        int16           "Max_PD_Entries"
        int16           "Max_VD_Entries"
        int16           "Max_Partitions"
        int16           "Configuration_Record_Length"
        int16           "Max_Primary_Element_Entries"
        int32           "Max_Mapped_Block_Entries"
        move 50         // Reserved
        section "Section Offsets"
            int32           "Controller_Data_Section"
            move 4          // Controller_Data_Section_Length
            int32           "Physical_Disk_Records_Section"
            move 4          // Physical_Disk_Records_Section_Length
            int32           "Virtual_Disk_Records_Section"
            move 4          // Virtual_Disk_Records_Section_Length
            int32           "Configuration_Records_Section"
            move 4          // Configuration_Records_Section_Length
            int32           "Physical_Disk_Data_Section"
            move 4          // Physical_Disk_Data_Section_Length
            int32           "BBM_Log_Section"
            move 4          // BBM_Log_Section_Length
            int32           "Diagnostic_Space"
            move 4          // Diagnostic_Space_Length
            int32           "Vendor_Specific_Logs_Section"
            move 4          // Vendor_Specific_Logs_Section_Length
        endsection
        move 256        // Reserved
    endsection

    gotoex ((Primary_Header_LBA+Controller_Data_Section)*512)
    section "Controller_Data_Section"
        hex 4           "Signature"
        IfEqual Signature 0xAD111111
            move 4          // CRC
            string 8        "Vendor ID"
            string 16       "Controller Serial"
            hex 2           "Vendor ID"
            hex 2           "Device ID"
            hex 2           "Sub Vendor ID"
            hex 2           "Sub DeviceID"
            string 16       "Product_ID"
            move 8          // Reserved
            move 448        // Vendor_Unique_Contorller_Data
        EndIf
    endsection

    gotoex ((Primary_Header_LBA+Physical_Disk_Records_Section)*512)
    section "Physical_Disk_Records_Section"
        hex 4           "Signature"
        IfEqual Signature 0x22222222
            move 4       // CRC
            int16       "Populated_PDEs"
            int16       "Max_PDE_Supported"
            move 52     // Reserved
            numbering 1{
                section "PDE #~"
                    hex 24      "PD_GUID"
                    hex 4       "PD_Reference"
                    binary[1]   "PD_Type*"
                    hex 1       "PD_Interface*"
                    binary[1]   "PD_State*"
                    move 1      // Reserved bits from PD_State
                    int64       "Configured_Size"
                    IfEqual PD_Interface* 0x00      // Unknown Path Infromation
                        move 18
                    EndIf
                    IfEqual PD_Interface* 0x01      // SCSC Path Information
                        binary[1]   "P0 LUN"
                        binary[1]   "P0 SCSI Target ID"
                        binary[1]   "P0 SCSI Channel"
                        binary[1]   "P0 Path Broken"
                        binary[1]   "P1 LUN"
                        binary[1]   "P1 SCSI Target ID"
                        binary[1]   "P1 SCSI Channel"
                        binary[1]   "P1 Path Broken"
                        move 10     // Reserved
                    EndIf
                    IfEqual PD_Interface* 0x02      // SAS Path Information
                        hex 8       "P0 SAS address"
                        hex 8       "P1 SAS address"
                        binary[1]   "P0 PHY identifier + broken"
                        binary[1]   "P1 PHY identifier + broken"
                    EndIf
                    IfEqual PD_Interface* 0x03      // SATA Path Information
                        hex 8       "P0 end device address"
                        hex 8       "P1 end device address"
                        binary[1]   "P0 PHY identifier + broken"
                        binary[1]   "P1 PHY identifier + broken"
                    EndIf
                    IfGreater PD_Interface* 0x03    // FC Path Information (or a reserved interface type)
                        move 18
                    EndIf
                    int16       "Block_Size"
                    move 4      // Reserved
                endsection
            }[(Populated_PDEs)]
        EndIf
    endsection

    gotoex ((Primary_Header_LBA+Virtual_Disk_Records_Section)*512)
    section "Virtual_Disk_Records_Section"
        hex 4           "Signature"
        IfEqual Signature 0xDDDDDDDD
            move 4       // CRC
            int16       "Populated_VDEs"
            int16       "Max_VDE_Supported"
            move 52     // Reserved
            numbering 1{
                section "VDE #~"
                    hex 24      "VD_GUID"
                    hex 2       "VD_Number"
                    move 2      // Reserved
                    binary[1]   "VD_Type*"
                    move 1      // Reserved
                    hex 2       "Primary Controller GUID CRC*"
                    binary[1]   "VD_State*"
                    binary[1]   "Init_State*"
                    int8        "Partially_Optimal_Drive_Failures_Remaining"
                    move 13     // Reserved
                    string 16   "VD_Name"
                endsection
            }[(Populated_VDEs)]
        EndIf
    endsection

    gotoex ((Primary_Header_LBA+Configuration_Records_Section)*512)
    section "Configuration_Records_Section"
        hex 4           "Signature"
        IfEqual Signature 0xEEEEEEEE
            section "Virtual Disk Configuration Record"
                move 4       // CRC
                hex 24      "VD_GUID"
                hex 4       "Timestamp (GPSTime)*"
                int32       "Sequence_Number"
                move 24     // Reserved
                int16       "Primary_Element_Count"
                int8        "Strip_Size*"
                hex 1       "Primary_RAID_Level"
                hex 1       "RAID_Level_Qualifier"
                int8        "Secondary_Element_Count"
                int8        "Secondary_Element_Seq"
                hex 1       "Secondary_RAID_Level"
                int64       "Block_Count"
                int64       "VD_Size"
                int16       "Block_Size"
                int8        "Rotate parity count"
                move 5      // Reserved
                numbering 0{
                    hex 4   "Spare ~ PD reference"
                }[8]
                binary[1]   "Cache Policies & Parameters*"
                move 7      // Vendor specfic Cache Policies & Parameters
                hex 1       "BG_Rate"
                move 3      // Reserved
                int8        "MDF Parity Disks"
                hex 2       "MDF Parity Generator Polynomial"
                move 1      // Reserved
                hex 1       "MDF Constant Generation Method"
                move 47     // Reserved
                move 192    // Reserved
                move 32     // V0
                move 32     // V1
                move 16     // V2
                move 16     // V3
                move 32     // Vendor Specific Scratch Space
                numbering 1{
                    IfGreater ~ Primary_Element_Count
                        move 4
                    Else
                        hex 4       "PD Reference #~"
                    EndIf
                }[(Max_Primary_Element_Entries)]
                numbering 1{
                    IfGreater ~ Primary_Element_Count
                        move 8
                    Else
                        int64       "PD #~ Starting LBA"
                    EndIf
                }[(Primary_Element_Count)]
            endsection
        EndIf

        IfEqual Signature 0x88888888
            section "Vendor Unique Configuration Record"
                move 4       // CRC
                hex 24      "VD_GUID"
            endsection
        EndIf

        IfEqual Signature 0x55555555
            section "Spare Assignment Record"
                move 4       // CRC
                hex 4       "Timestamp*"
                move 7      // Reserved
                binary[1]   "Spare_Type*"
                int16       "Populated_SAEs"
                int16       "Max_SAE_Supported"
                move 8      // Reserved
                numbering 1{
                    section "Spare Assignment Entry ~"
                        hex 24      "VD_GUID"
                        int16       "Secondary_Element"
                        move 6      // Reserved
                    endsection
                }[(Populated_SAEs)]
            endsection
        EndIf
    endsection

    gotoex ((Primary_Header_LBA+Physical_Disk_Data_Section)*512)
    section "Physical_Disk_Data_Section"
        hex 4           "Signature"
        IfEqual Signature 0x33333333
            hex 4       "CRC"
            hex 24      "PD_GUID"
            hex 4       "PD_Reference"
            hex 1       "Forced_Ref_Flag"
            hex 1       "Forced_PD_GUID_Flag"
            move 32     // Vendor Specific Scratch Space
            move 442    // Reserved
        EndIf
    endsection
end