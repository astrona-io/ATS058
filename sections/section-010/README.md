---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# Understand the Role of eBPF in Cilium

This section explains what eBPF is and how Cilium uses it. The first module follows an eBPF program from source code to the kernel: the compiler, the `bpf()` system call, the verifier and the just-in-time compiler. It then covers the hooks where programs run and the maps where they keep state. The second module shows how the Cilium agent turns pods, labels and policies into map entries, and how the programs read those entries to enforce policy and balance Services.

The third module teaches a fixed order of commands for inspecting the datapath on one node: the agent, the endpoint list, the IP cache, the policy map, the connection tracking table and the live event stream.

Each module has a playground and a graded lab. The section ends with a capstone lab and a knowledge check.

## Learning Outcomes

- Explain what the verifier proves about a program and what it does not prove.
- Name the hooks that Cilium uses and say what a program can see at each one.
- Read the service map and the endpoint map on a node and compare them with Kubernetes objects.
- Describe the roles of the agent, the operator, the CNI plugin and Hubble.
- Explain how a security identity replaces an IP address in a policy rule.
- Trace a CiliumNetworkPolicy from the object to a policy map entry and a packet decision.
- Name the program types and explain tail calls, pinned maps, BTF and how the agent builds the datapath.
- Read Cilium custom resources and follow a request between pods, with tunnel or native routing.
- Inspect the datapath of one node and explain a dropped request with the endpoint list, the IP cache, the policy map and live events.
