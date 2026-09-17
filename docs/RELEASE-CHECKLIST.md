# Release checklist

Do not attach a driver package to a GitHub Release until every item is true.

- [ ] The generated patch passes `git apply --check` against a clean, pinned
      upstream commit.
- [ ] A clean x64 release build completes from that checkout.
- [ ] Driver Verifier and functional testing pass on more than one supported
      Windows and Mac configuration.
- [ ] The package contains no private key, test certificate, user name,
      absolute build path, serial number, or static-IP configuration.
- [ ] The INF is limited to `USB\VID_05AC&PID_1902`.
- [ ] The catalog and driver are signed through the intended Microsoft kernel
      driver signing workflow.
- [ ] `signtool verify /kp /v` succeeds for both the catalog and driver.
- [ ] SHA-256 hashes and a versioned changelog are published with the asset.
- [ ] The Windows/macOS setup guide has been reviewed and tested from a fresh
      machine state.

Until then, publish source and test evidence only. Never ask users to disable
Secure Boot, enable test-signing mode, or install a locally trusted test root
as part of a normal public release.
