---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Policy, Masquerading And Host Firewall Without iptables

Services are not the only job that iptables does in a Kubernetes node. Network policy, address masquerading and node firewalls also use netfilter in many platforms. This module shows how Cilium does these jobs with eBPF, which settings turn the eBPF versions on, and how to decide between the two platforms.

The module has four parts. The first part covers network policy: how iptables-based platforms enforce it and how Cilium enforces it with identities and policy maps. The second part covers masquerading with eBPF. The third part covers the host firewall, which applies policy to the node itself. The fourth part compares the two platforms and lists the iptables rules that remain on a Cilium node.

## Learning objectives

After this module you can:

- Explain how an iptables-based platform enforces policy and what limits that design has.
- Read the policy enforcement state of an endpoint and the policy map of a node.
- Explain what masquerading does and turn on the eBPF implementation.
- Describe the host firewall and the audit mode that prevents a lockout.
- Compare the two platforms on lookup, updates, identity, visibility and operations.

## Before you start

You need to know how kube-proxy and the Service chains work, what a map and an agent are, and what a CiliumNetworkPolicy is. You need basic `helm` and `kubectl` knowledge.

The playground is a two-node `kind` cluster that runs Cilium next to kube-proxy, so Services are handled by kube-proxy at the start. It runs the example application: a `probe` Deployment with three pods and a Service in `starfleet`, a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. You run commands as the cluster administrator, and `kubectl` already points at the playground. Launch it now and keep it open while you read:

<!-- astrona:playground -->
