---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# The Cilium Agent, Identities And The Datapath

The kernel can run eBPF programs, but it knows nothing about pods, labels, Services or network policies. The Cilium components close that gap. This module explains which component does which job, how a pod becomes an endpoint with a security identity, and how a network policy and a Service become entries in maps that programs read for every packet.

The module has two parts. The first part covers the agent, the operator, the CNI plugin, endpoints and security identities. The second part follows a `CiliumNetworkPolicy` from the YAML file to a verdict on a packet, and shows that Service load balancing uses the same mechanism.

## Learning objectives

After this module you can:

- Name the Cilium agent, operator, CNI plugin, Hubble and Hubble Relay and state what each one does.
- Describe what happens when a pod starts and which component creates the endpoint.
- Explain what a security identity is and why policy uses identities instead of IP addresses.
- Describe how a `CiliumNetworkPolicy` becomes policy map entries and how a tc program uses them.
- Explain why a policy rule names the pod port and not the Service port.

## Before you start

You need basic Kubernetes knowledge: pods, labels, namespaces, Services and `kubectl`. You need to know what an eBPF program, a hook and a map are.

The playground is a two-node `kind` cluster with Cilium installed and Hubble Relay enabled. It runs the example application: a `probe` Deployment and Service in `starfleet`, a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. You run commands as the cluster administrator, and `kubectl` already points at the playground. Launch it now and keep it open while you read:

<!-- astrona:playground -->
