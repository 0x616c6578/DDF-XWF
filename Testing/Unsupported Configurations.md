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