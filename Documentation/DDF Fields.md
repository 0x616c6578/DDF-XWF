# DDF Metadata fields
The following field descriptions have been extracted from the [DDF Specification](https://www.snia.org/tech_activities/standards/curr_standards/ddf), to provide context for field values which cannot be easily interpreted in the Template view.  Fields in the '_Global_', '_Local_', and '_All_' templates may be suffixed with an asterisk (*) to indicate additional documentation is available, in the relevant section below.


**General tips**:
- A field with a value comprised entirely of `0xF` is "reserved" or likely unused in the current configuration
- A field with a value of `-1` indicates the value has not been set.
- Shorthand field descriptions have been used in the table below:
  - For _bits_, the interpretation (value) provided is valid for when the bit is true/set (`1`). Assume the inverse if the bit is not set, unless there is an explicit _not_ value specified e.g. "Revertible (!committable)"
- All timestamps specified in the DDF metadata are in _GPS Time_. This is similar to Unix time, though it has a different epoch: **6 Jan 1980**.  There is currently no valid variable type available in X-Ways templates so an integer has been provided, representing the number of seconds since the epoch.

<br>

## DDF Header
| Field | Description |
| - | - |
| DDF_rev | This relates to the DDF metadata veresion used. `01.02.00` is most common but you may also see `02.00.00`.  Practically, this doesn't change how you interpet header as later versions don't change the strcuture.  Rather, they add fields in locations which were previously "reserved". |
| Sequence_Number | Should be updated every time a change is made to the configuration e.g. added PDs, VDs, etc.  Testing is needed to confirm this. |
| Timestamp | DDF Header update time. *GPS Time (seconds since 6 Jan 1980)*.
| Foreign_Flag | This DDF structure has not yet been imported by the last controller which interacted with it. |

## Physical Disk Records PDE 
| Field | Description |
| - | - |
| PD_Type | bit 0: Forced PD_GUID<br>bit 1: VD member<br>bit 2: Global spare<br> bit 3: Local spare<br>bit 4: Foreign<br>bit 5: Pass-through/legacy disk
| PD_Interface | Final character: <br> - `0` (Unknown) <br> - `1` (SCSI) <br> - `2` (SAS) <br> - `3` (SATA)<br> - `4` (FC)
| PD_State | bit 0: online<br>bit 1: failed<br>bit 2: rebuilding<br>bit 3: in transition (replacing a PD)<br>bit 4: PFA/SMART errors<br>bit 5: Un-recovered read errors<br>bit 6: Missing

## Virtual Disk Records VDE
| Field | Description |
| - | - |
| VD_Type | bit 0: Shared<br>bit 1: Disk grouping enforced<br>bit 2: VD_Name in unicode format (vs. ASCII)<br>bit 3: Owner ID Valid |
| Primary Controller GUID CRC | 16-bit CRC of the last controller which owned the VD (in a clustered environment) |
| VD_State | bits 0-2: state<br> - `000` (Optimal)<br> - `001` (Degraded)<br> - `010` (Deleted)<br> - `011` (Missing)<br> - `100` (Failed)<br> - `101` (Partially optimal; can recover)<br> - `110` (Offline)<br>bit 3: Morphing<br>bit 4: VD not consistent|
| Init_State | bits 0-1: state<br> - `00` (Not initialised)<br> - `01` (In prgoress)<br> - `10` (Initialised)<br>bits 6-7 user access mode:<br> - `00` (read/write)<br> - `10` (read only)<br> - `11` (blocked) |

## Virtual Disk Configuration Record
| Field | Description |
| - | - |
| Timestamp (GPSTime) | Last time the VD was configured/updated. *GPS Time (seconds since 6 Jan 1980)*. |
| Strip_Size | Stripe depth is `(2^n)*512` bytes. |
| Cache Policies & Parameters | bit 0: Writeback  (!writethrough)<br>bit 1: Adaptive (!always)<br>bit 2: Read ahead<br>bit 3: Adaptive (! always)<br>bit 4: Write caching allowed if battery low or not present<br>bit 5: Write caching allowed<br>bit 6: Read caching allowed<br>bit 7: Vendor-specific caching algorithm|

## Spare Assignment Record
| Field | Description |
| - | - |
| Timestamp | Last time the Spare assignment record was configured/updated. *GPS Time (seconds since 6 Jan 1980)*. |
| Spare_Type | bit 0: Dedicated (!global)<br>bit 1: Revertible (!committable)<br>bit 2: Active<br>bit 3: Enclosure affinity
