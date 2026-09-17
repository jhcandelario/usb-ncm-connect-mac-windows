# Architecture and scope

## Device-specific compatibility path

The Windows inbox path assumes a CDC-NCM control interface with one interrupt
notification endpoint. The tested Apple device (`05AC:1902`) supplies no such
endpoint. It also exposes two control/data functions without IADs. Those
descriptors are sufficient for data transfer, but not for the unmodified
sample's discovery and carrier-state sequence.

The compatibility path is deliberately gated on the exact vendor/product ID.
It accepts a zero-endpoint control interface only for that ID; all other NCM
devices remain on the upstream validation path.

When the Apple composite parent is bound, WDF must select every exposed USB
interface in the configuration. The patch retains the first NCM function's
descriptors and configures the complete interface set. It then skips the
missing notification pipe and reports carrier up only while the data interface
is in its working state.

## Why source first

Windows kernel-mode code is security-sensitive. A Git repository should make
the complete change reviewable, reproducible, and independently signable.
Prebuilt test-signed `.sys` files and their trust certificates do not belong in
source control or a normal end-user download.

For public use with Secure Boot enabled, submit the final package through the
[Windows Hardware Dev Center driver-signing process](https://learn.microsoft.com/windows-hardware/drivers/dashboard/code-signing-reqs).
An EV certificate can be used to establish the Hardware Dev Center account,
but it does not itself replace Microsoft kernel-driver signing.

## Non-goals

- generic CDC-NCM support
- Thunderbolt or USB4 support
- an assurance of 10 Gb/s throughput
- automatic static IP, firewall, routing, or Internet Sharing changes
- a bypass of Secure Boot or Windows driver-signing protections
