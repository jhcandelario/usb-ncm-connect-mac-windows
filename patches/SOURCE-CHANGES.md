# Source-change inventory

This inventory targets Microsoft's
[`release_21H2`](https://github.com/microsoft/NCM-Driver-for-Windows/tree/release_21H2)
branch at commit `48d93213022dce92d518adc60c91fbbb0beab498`. The companion
[`0001-apple-05ac-1902-device-compatibility.patch`](0001-apple-05ac-1902-device-compatibility.patch)
passes `git apply --check` against that exact baseline. This page explains the
intent behind the changes so a reviewer does not need to reverse-engineer it.

## `host/device.h`

Add a private `BOOLEAN m_IsAppleNcm1902 = FALSE;` member.

## `host/device.cpp`

1. Define vendor ID `0x05AC`, product ID `0x1902`, and nominal link speed
   `10000000000ULL`.
2. In `InitializeDevice`, read the USB device descriptor and set
   `m_IsAppleNcm1902` only when both IDs match.
3. Keep the normal three-pipe validation for every other device. For the
   exact Apple device, require only both bulk pipes.
4. In `SelectConfiguration`, permit a zero-endpoint control interface only
   for the Apple device. Preserve the first Apple control/data interface and
   the first NCM/ECM functional descriptors while scanning the two functions.
5. When that Apple device owns the composite parent, create setting pairs for
   every USB interface returned by `WdfUsbTargetDeviceGetNumInterfaces` and
   select all of them at alternate setting zero. Retain the original two-pair
   behavior for all other devices.
6. In `RetrieveInterruptPipe`, accept zero configured control pipes only for
   the Apple device. Do not create or start a pipe in that case.
7. In `EnterWorkingState`, when the Apple device has no control pipe, set
   receive/transmit link speed to 10 Gb/s and set link state true. In
   `LeaveWorkingState`, set that link state false. Otherwise preserve the
   upstream pipe start/stop behavior.

## `host/UsbNcmSample.inf`

See [INF-CHANGES.md](INF-CHANGES.md). It is UTF-16LE in the upstream source,
so edits must preserve encoding and the catalog must be regenerated.

## Required release gate

Before publishing a binary release, generate the patch directly from a clean
upstream checkout, then pass all of these checks:

```powershell
git apply --check .\patches\0001-apple-05ac-1902-device-compatibility.patch
msbuild .\UsbNcmSample.sln /p:Configuration=Release /p:Platform=x64
signtool verify /kp /v .\AppleNcm1902.sys
```

The checked-in project includes the generated C/C++ patch but no binary
release. The INF/package rename remains encoding-sensitive and is documented
separately. A clean, independently repeatable build is still required before a
public package can be responsibly tagged.
