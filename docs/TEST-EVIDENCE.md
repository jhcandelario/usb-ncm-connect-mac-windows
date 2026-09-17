# Recorded test evidence

The following is one reproducible test record, not a benchmark promise.

| Test | Result |
| --- | --- |
| Physical bus | SuperSpeedPlus on the tested Windows USB controller |
| Windows-reported NCM link | 10 Gb/s nominal |
| IPv4 reachability | Bidirectional ping succeeded |
| MTU 1500 validation | 1472-byte ICMP payload with DF: 5/5 replies, about 1 ms |
| MTU 1500 throughput | `iperf3`, Windows to Mac, 4 streams, 20 s: 6.24 Gb/s |
| Jumbo-frame validation | MTU 9000 both ends; 8972-byte ICMP payload with DF: 10/10 replies, about 1 ms |
| MTU 9000 throughput | `iperf3`, Windows to Mac, 4 streams, 20 s: 6.52 Gb/s |
| MTU 9000 throughput | `iperf3`, Mac to Windows, 4 streams, 20 s: 5.61 Gb/s, 0 retransmits reported |
| Bidirectional stability | `iperf3 --bidir`, 4 streams, 20 s: 6.25 Gb/s aggregate; concurrent ping 25/25 replies, 0 loss, 1–5 ms |

The bidirectional result was approximately 2.07 Gb/s from Windows to Mac and
4.18 Gb/s from Mac to Windows. Throughput is sensitive to controller, cable,
CPU, offloads, stream count, and endpoint implementation.

## RPC comparison note

The recovered earlier handoff record contains no completed llama.cpp RPC,
Ethernet, or Wi-Fi measurements. It records a proposed dedicated 10GbE path
(estimated 8–9.5 Gb/s) and 5GbE fallback (estimated 3.5–4.7 Gb/s), not test
results. A future RPC comparison must use the same model, context length,
GPU/Metal layer split, llama.cpp revision, and token-generation command on each
transport.
