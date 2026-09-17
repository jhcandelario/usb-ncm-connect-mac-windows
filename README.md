# Apple Mac USB NCM compatibility patch for Windows

If you landed here because a Mac and a Windows PC are connected by USB-C but
Windows only gives you a mysterious Code 10, you are in the right place. This
is an experimental, source-first compatibility patch for connecting an Apple
Silicon Mac directly to Windows over the Mac's USB-C NCM device
(`USB\\VID_05AC&PID_1902`).

The inbox Windows NCM driver rejects this Mac device because its NCM control
interfaces have no CDC notification endpoint and the device exposes two NCM
functions without Interface Association Descriptors (IADs). This project
documents the observed layout and records the source changes against Microsoft's
[NCM Driver for Windows sample](https://github.com/microsoft/NCM-Driver-for-Windows).

## Status

**Experimental; not a production driver.** The patch was validated on one
Windows 11 x64 host and one Apple Silicon Mac. It produced a working direct
IPv4 link and multi-stream `iperf3` throughput of 6.24 Gb/s with MTU 1500 and
6.52 Gb/s in the Windows-to-Mac direction with MTU 9000. That is useful
evidence, not a compatibility guarantee for another Mac, Windows build, USB
controller, port, or cable.

No driver binary, catalog, signing certificate, machine path, account name,
or network configuration is committed to this repository. A public release
must be built reproducibly from source and signed through Microsoft's normal
kernel-driver signing path before it can work on Secure-Boot-enabled Windows.

## What the patch changes

- Matches only the Apple composite device `USB\\VID_05AC&PID_1902`.
- Permits that device's zero-endpoint NCM control interface while retaining
  the original validation for every other device.
- Selects the first Apple NCM control/data pair while configuring all exposed
  interfaces, which is required when the composite parent is bound.
- Does not start a nonexistent notification pipe; it supplies carrier state
  and a 10 Gb/s nominal link speed while the data alternate setting is active.
- Renames the sample service and package so it cannot collide with the
  upstream sample.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the design,
[patches/SOURCE-CHANGES.md](patches/SOURCE-CHANGES.md) for the reviewable
change inventory, and [docs/TEST-EVIDENCE.md](docs/TEST-EVIDENCE.md) for the
recorded tests.

## Boundaries

This is not affiliated with Apple or Microsoft. It is not an Apple driver,
does not alter macOS, and does not make a USB-C port into Thunderbolt or USB4.
The physical USB link must already negotiate SuperSpeedPlus for 10 Gb/s-class
performance. Do not use test-signed packages on a system that requires Secure
Boot.

The next milestone is a separate, reviewed Windows/macOS setup guide. Until
then, this repository intentionally does not provide one-click installation
instructions or release binaries. We would rather be clear about what is known
than make an experimental driver look effortless.

## Upstream and license

The patch targets the `release_21H2` branch of Microsoft's NCM sample. The
upstream sample is MIT licensed; this repository's patch and documentation are
also MIT licensed. Preserve the upstream notices when building or redistributing
a derivative.

## Contributing

Please include all of the following with a compatibility report:

- Windows version and USB controller model
- Mac model and macOS version
- USB cable and negotiated USB speed
- device descriptors (redact serial numbers)
- MTU and a bidirectional `iperf3` result
- any Driver Verifier or crash-dump findings

Never attach signing keys, private certificates, serial numbers, or full
machine-specific setup logs.
