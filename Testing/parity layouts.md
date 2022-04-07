## Parity Layout Options for mdadm
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