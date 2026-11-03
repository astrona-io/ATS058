---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# How kube-proxy Uses iptables, And Where It Stops Scaling

Before Cilium, most clusters handled Services with kube-proxy and iptables. To judge what Cilium improves, you must know exactly what kube-proxy writes into the kernel and which parts of that model grow with the cluster. This module reads real kube-proxy rules and then explains the limits of the model.

The module has two parts. The first part explains the netfilter hooks, the chains that kube-proxy creates for a Service and the path of one connection through them. The second part covers the scaling limits: the length of the rule lists, the cost of syncing rules, the connection tracking table and the problem of policy that is based on IP addresses.

## Learning objectives

After this module you can:

- Name the netfilter hooks and the NAT chains that kube-proxy uses for a Service.
- Read the `KUBE-SERVICES`, `KUBE-SVC` and `KUBE-SEP` chains of a Service in `iptables-save` output.
- Explain how kube-proxy spreads connections across backends with probabilities.
- Describe why rule lists, rule syncs and IP-based policy become a problem in large clusters.
- State what the iptables model does not give you, such as per-flow visibility.

## Before you start

You need to know what a Kubernetes Service and an EndpointSlice are. You do not need to know iptables, which the module explains.

The playground is a two-node `kind` cluster that runs Cilium next to kube-proxy in iptables mode, so Services are handled by kube-proxy at the start. It runs the example application: a `probe` Deployment with three pods and a Service in `starfleet`, a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. You run commands as the cluster administrator, and `kubectl` already points at the playground. Launch it now and keep it open while you read:

<!-- astrona:playground -->
