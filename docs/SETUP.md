# Set up and test the direct Mac ↔ Windows link

This guide starts **after** the compatibility driver has been installed by a
proper release package or by a developer building the source. It does not ask
you to disable Secure Boot, enable test-signing mode, trust a test certificate,
or alter your ordinary Wi-Fi/Ethernet connection.

The goal is a small private network between just these two machines. It does
not need a router, gateway, or DNS server.

## Before you begin

- Use a USB-C cable that supports USB 3.2 Gen 2 / 10 Gb/s data. Charging-only
  cables will not work.
- Plug directly into a 10 Gb/s-capable USB port when possible; avoid docks and
  hubs while diagnosing.
- Connect the Mac and PC, then confirm Windows shows the adapter without a
  warning icon.
- Pick an unused private subnet. This guide uses `192.168.88.0/24`; replace it
  if it overlaps with a network you already use.

## Windows 11

Open **PowerShell as Administrator**, then identify the new adapter:

```powershell
Get-NetAdapter | Format-Table -Auto Name, Status, LinkSpeed, InterfaceDescription
```

Use the adapter name from that output in the next command. This example assigns
Windows `192.168.88.1` with a `/24` mask. It deliberately has no default
gateway, so this private link cannot take over your internet traffic.

```powershell
New-NetIPAddress -InterfaceAlias 'Apple Mac USB NCM' `
  -IPAddress 192.168.88.1 -PrefixLength 24
```

`New-NetIPAddress` is Microsoft’s supported PowerShell command for assigning
an address to an interface. If the adapter already has an address, inspect it
first with `Get-NetIPAddress -InterfaceAlias 'Apple Mac USB NCM'` rather than
adding a second, conflicting address. [Microsoft reference](https://learn.microsoft.com/en-us/powershell/module/nettcpip/new-netipaddress)

## macOS

1. Open **System Settings → Network**.
2. Select the new USB Ethernet/NCM service, then choose **Details → TCP/IP**.
3. Set **Configure IPv4** to **Manually**.
4. Enter IP address `192.168.88.2` and subnet mask `255.255.255.0`.
5. Leave Router and DNS blank, then click **OK** and **Apply**.

Apple documents manual IPv4 configuration under Network → service → Details →
TCP/IP. [Apple’s guide](https://support.apple.com/guide/mac-help/use-dhcp-or-a-manual-ip-address-on-mac-mchlp2718/mac)

## Confirm basic reachability

From Windows:

```powershell
ping 192.168.88.2
```

From macOS:

```sh
ping -c 10 192.168.88.1
```

Both commands should receive replies. If they do not, stop here and capture:

- the Windows adapter status and link speed;
- the macOS Network service status;
- `ipconfig /all` (redact physical addresses); and
- the cable and USB ports in use.

## Measure throughput before changing MTU

Install `iperf3` on both machines. Start a server on the Mac:

```sh
iperf3 -s
```

On Windows, run a four-stream test:

```powershell
iperf3 -c 192.168.88.2 -P 4 -t 20
```

Then reverse the direction:

```powershell
iperf3 -c 192.168.88.2 -P 4 -t 20 -R
```

Record both numbers, plus your MTU and cable/port details. Directional results
often differ, and one number is not enough to characterize the link.

## Optional: test jumbo frames

Do this only after the MTU-1500 test is stable. Set **both** ends to MTU 9000;
an MTU mismatch causes confusing, partial failures.

On Windows:

```powershell
netsh interface ipv4 set subinterface "Apple Mac USB NCM" mtu=9000 store=persistent
```

On macOS, open **System Settings → Network → [USB service] → Details →
Hardware**, set Configure to **Manually**, set MTU to **Custom (9000)**, then
apply the change.

Verify the full payload path from Windows:

```powershell
ping 192.168.88.2 -f -l 8972 -n 10
```

If all replies succeed, repeat the two `iperf3` commands above and optionally:

```powershell
iperf3 -c 192.168.88.2 --bidir -P 4 -t 20
```

## Keep the report useful

When sharing results, include Windows/macOS versions, controller model, cable,
negotiated link speed, MTU, both `iperf3` directions, and packet loss. Redact
serial numbers, MAC addresses, public IPs, and any signing material.
