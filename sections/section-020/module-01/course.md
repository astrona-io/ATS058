---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Lookups, Updates And Shorter Packet Paths

Cilium is not only a different way to write the same rules. It changes how the kernel finds the rule for a packet, how a change reaches the kernel and how many steps a packet takes before it reaches its destination. This module explains these three differences at the level of the data structures and the kernel code paths.

The module has two parts. The first part compares a lookup in a hash map with the walk through a chain of rules, and it compares incremental updates with rewriting a whole rule set. The second part covers the places where Cilium shortens the packet path: translation at the socket, eBPF host routing and the optional XDP hook.

## Learning objectives

After this module you can:

- Explain why a hash map lookup takes constant time and a rule chain takes time that grows with the number of rules.
- Describe how Cilium updates one map entry when a Service changes.
- Explain what socket-level load balancing is and which step of the packet path it removes.
- Describe what eBPF host routing and XDP change in the path of a packet.
- Read the Service frontends and backends of a Cilium agent with `cilium-dbg`.

## Before you start

You need to know what a Kubernetes Service is and what an eBPF map is. You do not need to know iptables.

The playground is a two-node `kind` cluster with Cilium installed and Hubble Relay enabled. It runs the example application: a `probe` Deployment and Service in `starfleet`, a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. You run commands as the cluster administrator, and `kubectl` already points at the playground. Launch it now and keep it open while you read:

<!-- astrona:playground -->
