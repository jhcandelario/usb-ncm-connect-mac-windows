# INF/package changes

The Microsoft sample's `host/UsbNcmSample.inf` is UTF-16LE. Make these changes
with an editor that preserves that encoding, then regenerate the catalog.

| Upstream value | Compatibility value |
| --- | --- |
| `UsbNcmFnSample.cat` | `AppleNcm1902.cat` |
| `UsbNcmSample.sys` | `AppleNcm1902.sys` |
| `USB\MS_COMP_WINNCM` | `USB\VID_05AC&PID_1902` |
| `UsbNcm` service | `AppleNcm1902` service |
| `UsbNcm Host Device` | `Apple Mac USB NCM Network Adapter` |
| `UsbNcm Host Service` | `Apple 05AC:1902 USB NCM Host Service` |
| `NetAdpaterNcmSample` provider string | `Apple NCM Compatibility Driver` |

Before the hardware ID line, add these comments:

```ini
; Apple exposes two NCM functions without IADs. Bind the composite parent so
; the WDF USB target owns each control/data interface pair together.
```

The hardware match must remain exact. Do not replace it with a generic
CDC-NCM class match: this compatibility path intentionally handles a
nonstandard descriptor layout.
