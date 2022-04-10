template "DDF - Reconstruction"
description "DDF metadata superblock VD reconstruction fields"
applies_to disk
sector-aligned
read-only
big-endian
fixed_start -512
requires 0 "DE11DE11"


begin
    section "Navigation Data (disregard)"
        move 96
        int64           "Primary_header_LBA"
        move 32
        int16           "Max_Primary_Element_Entries"
        move 62         
        int32           "Physical_Disk_Records_Section"
        move 4          
        int32           "Virtual_Disk_Records_Section"
        move 4          
        int32           "Configuration_Records_Section"
        move 4
        int32           "Physical_Disk_Data_Section"
    endsection

	gotoex ((Primary_Header_LBA+Configuration_Records_Section)*512)
	section "Configuration Records (local)"
		hex 4			"Signature"
		move 4			// CRC
		IfEqual Signature 0xEEEEEEEE
			hex 24		"VD Guid"
			move 32		// Reserved
			int16			"Primary_Element_Count"
			int8			"Strip_Size = (2^n)*512"
			int8			"Primary_RAID_Level (PRL)"
			int8			"RAID_Level_Qualifier (RLQ)"
			int8			"Secondary_Element_Count"
			int8			"Secondary_Element_Sequence"
			int8			"Secondary_RAID_Level (SRL)"
			move 440	

			numbering 1{
				hex 4		"PD Reference #~"
			}[(Primary_Element_Count)]

			move (8*Max_Primary_Element_Entries)
		EndIf
		IfEqual Signature "0x55555555"
			int32			"Timestamp (GPSTime)"
			move 7		// Reserved
			binary[1]	"Spare Type (see documentation)"
			int16			"Populated SAEs"
			int16			"Max SAE"
			move 8		// Reserved
			
		EndIf
		IfEqual Signature "0x88888888"
			hex 24		"VD Guid"
		EndIf
	endsection

	gotoex ((Primary_Header_LBA+Physical_Disk_Data_Section)*512)
	section "Physical Disk Data (current disk)"
        move 32
        hex 4           "PD Reference"
	endsection
end