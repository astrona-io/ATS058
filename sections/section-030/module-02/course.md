---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Replacing kube-proxy With Cilium

Cilium can handle Services itself, with eBPF programs and maps, so that kube-proxy and its iptables rules are not needed. This module explains how the replacement works for in-cluster and external traffic, what changes in the configuration, and how to migrate a running cluster without leaving old rules behind.

The module has two parts. The first part covers how Cilium handles a ClusterIP, a NodePort and an external client, the optional direct server return mode, and how to verify that the replacement is active. The second part covers the migration steps, the cleanup of the old rules, the iptables rules that remain on the node and the failure cases.

## Learning objectives

After this module you can:

- Explain how Cilium handles ClusterIP and NodePort Services without kube-proxy.
- Set `kubeProxyReplacement`, `k8sServiceHost` and `k8sServicePort` and explain why the last two are needed.
- Verify with `cilium-dbg` that the replacement is active.
- Migrate a cluster: restart the agents, delete the kube-proxy DaemonSet and ConfigMap and clean the old rules.
- Name the iptables rules that stay on a node when Cilium replaces kube-proxy.

## Before you start

You need to know how kube-proxy and the Service chains work, and what a map and an agent are. You need basic `helm` and `kubectl` knowledge.

The playground is a two-node `kind` cluster that runs Cilium next to kube-proxy, so Services are handled by kube-proxy at the start. The `probe` Deployment has three pods. The example application also has a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. You run commands as the cluster administrator, and `kubectl` already points at the playground. Launch it now and keep it open while you read:

<!-- astrona:playground -->
