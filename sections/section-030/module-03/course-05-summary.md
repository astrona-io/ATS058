---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Summary

An iptables-based platform enforces network policy with ipsets and chains that match IP addresses. Every pod change updates sets and rules on several nodes, and the chains grow with the number of policies. Cilium gives each group of pods with the same labels a security identity, translates an address to an identity with the `ipcache` map and checks the identity, port and protocol in the policy map of the endpoint. A pod that restarts with a new address keeps its identity, so only one map entry changes.

Masquerading replaces the source address of traffic that leaves the cluster with the node address, so replies return to the node. Cilium uses iptables for this by default and uses an eBPF program when `bpf.masquerade` is true. The eBPF mode has more requirements, and the agent reads the setting when it starts.

The host firewall applies Cilium policy to the node with a node selector and cluster-wide policies. It is off by default, and the audit mode of the host endpoint lets you see what a policy would drop before it blocks anything. A Cilium node can still hold some iptables chains for integration with the host, and the sign of a finished migration is that no kube-proxy rule remains.

Key facts:

- Cilium decides policy with two map lookups: identity first, then the policy entry.
- The agent status shows the masquerading mode.
- The host firewall is enabled with `hostFirewall.enabled=true`.
- Audit mode prevents a lockout while you build a host policy.

<!-- astrona:playground:destroy -->
