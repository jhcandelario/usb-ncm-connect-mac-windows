# Source-change inventory

This inventory targets Microsoft's
[`release_21H2`](https://github.com/microsoft/NCM-Driver-for-Windows/tree/release_21H2)
branch. It is deliberately an implementation specification, not a patch file:
a binary or a patch that cannot be checked with `git apply --check` is not a
valid public release artifact.

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

The checked-in project does not yet include that generated patch or a binary
release. This is intentional: it needs one clean, independently repeatable
build before a public package can be responsibly tagged.
