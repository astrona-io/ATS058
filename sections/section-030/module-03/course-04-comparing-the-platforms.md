---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Comparing The Platforms

You now know how an iptables-based platform and Cilium handle Services, policy, masquerading and the node firewall. This part puts the results side by side, names the rules that stay on a Cilium node, and gives the decision points for a migration. It uses the same words as the exam objective: an eBPF-based platform and an iptables-based platform.

## Side by side

| Topic | iptables-based platform | eBPF-based platform with Cilium |
| --- | --- | --- |
| Service lookup | Ordered rule chains, or IPVS or nftables with hash tables | Hash maps and socket hooks |
| Service update | Rewrite of the rule set, sometimes the whole table | Update of single map entries |
| Policy basis | IP addresses in ipsets and chains | Numeric security identities |
| Policy lookup | Chain walk or set match | Two map lookups |
| Connection tracking | Netfilter conntrack with a fixed table | eBPF connection tracking maps, sized from the node |
| Visibility | Counters and logs, per-flow detail needs extra tools | Flow events from the datapath, read with Hubble |
| Masquerading | iptables MASQUERADE | iptables or eBPF |
| Node firewall | Separate iptables rules | Host firewall with identities |

The table does not say that iptables is wrong. It says where the design of each platform puts its cost. A small cluster with few Services runs well on iptables.

## Rules that stay on a Cilium node

Cilium does not remove netfilter from the node. The agent may install a few iptables chains, for example `CILIUM_PRE_mangle`, `CILIUM_FORWARD`, `CILIUM_INPUT`, `CILIUM_OUTPUT` and `CILIUM_POST_nat`. The exact set depends on the release and the settings. They exist to integrate with the host network stack and with other software, for example to mark traffic. They do not hold the Service or policy decision.

List them on a node:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- iptables-save | grep -c CILIUM
kubectl -n kube-system exec ds/cilium -c cilium-agent -- iptables-save | grep -c KUBE
```

The first command counts the lines that mention `CILIUM`. The second counts the lines that mention `KUBE`. After a complete migration, the second number should be 0. A Cilium node can show a positive first number and still run all Service and policy decisions in eBPF.

## Host routing

Even with eBPF programs, a packet may still travel through the netfilter hooks of the host network stack, because the packet takes the legacy path through the host. Cilium has an eBPF host routing mode that skips this path for traffic between pods and out of the node. It needs a recent kernel. The Helm value `bpf.hostLegacyRouting` controls it, and the agent status shows the mode in the line that starts with `Host Routing`.

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep "Host Routing"
```

## Decision points for a migration

- Kernel: the eBPF features need a kernel that is new enough, and every node must have it. Check the system requirements of your release.
- Other software: tools that parse iptables output, or that add their own rules, may need changes.
- Observability: your team must learn `cilium-dbg` and Hubble in place of `iptables-save`.
- Rollback: keep the old rules and kube-proxy manifests until the new state is verified on every node.
- Scale: the largest gain is in clusters with many Services, many pods or high connection rates.

## What you now know

You can compare the two platforms by lookup, update, policy basis, connection tracking, visibility, masquerading and node firewall. You know that a Cilium node can still hold iptables rules for integration, and that the number of `KUBE` rules should be zero after the migration. You can name the points that decide a migration.

## Common pitfalls

> [!WARNING]
> Do not read a positive count of `CILIUM` lines as a failed migration. Only the `KUBE` rules show that kube-proxy is still active. Do not choose a platform on one benchmark: the gains depend on the number of Services, on the kernel and on the traffic pattern of your cluster.
