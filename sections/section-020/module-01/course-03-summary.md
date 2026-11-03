---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Summary

A netfilter rule chain is read in order, so the cost of a new connection grows with the number of rules in the chain, and each update rewrites rules in the kernel. A Cilium service map is a hash map, so a lookup costs the same for ten Services and for ten thousand Services. The agent updates only the entries that belong to a change, for example one backend entry when a pod starts. A map has a fixed maximum size, so the constant lookup cost comes with a capacity that must be sized.

Cilium also shortens the packet path. Socket load balancing replaces the cluster IP with a pod address once, when the application calls `connect()`, so later packets need no destination translation. eBPF host routing lets a program redirect a packet to the destination interface without the host network stack. XDP lets a program decide in the network driver, before the kernel builds its packet structure, and Cilium can use it for traffic that enters the node from outside.

These features depend on the kernel version, the network driver and the Helm values. Cilium falls back to an older path when a node cannot support a feature, so the agent status is the source of truth for what a node runs.

Key facts:

- A hash map lookup does not depend on the number of entries.
- Connection tracking means only the first packet of a connection is looked up in both models.
- The socket hook runs at `connect()`, before any packet exists.
- `cilium-dbg status --verbose` shows which datapath features the agent enabled.

<!-- astrona:playground:destroy -->
