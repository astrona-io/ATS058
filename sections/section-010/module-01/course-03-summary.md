---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# Summary

An eBPF program is bytecode that a user space loader submits to the kernel with the `bpf()` system call. The kernel verifier analyzes every path of the program and rejects it if it can touch invalid memory or fail to end. The kernel then translates the accepted program to machine code and attaches it to a hook. The Cilium agent is the loader, and it needs capabilities that ordinary application pods do not have.

The verifier proves that a program is safe to execute. It does not prove that the program expresses the policy the administrator intended. Support for program types, map types and helper functions depends on the kernel of each node, so features can differ between nodes.

A hook is the place where a program runs, and it decides what the program can see. Cilium uses tc hooks on pod and node interfaces, optional XDP hooks in the network driver and socket address hooks that translate Service addresses when an application connects. Maps hold the state that programs read. The agent writes Service, endpoint, identity and policy state into maps from the Kubernetes API, and the programs look it up for every packet.

Key facts:

- The verifier checks safety, not intent.
- A map has a fixed maximum size.
- The Service object states the desired state, and the map shows the state that the kernel uses.
- `cilium-dbg map list` and `cilium-dbg bpf lb list` show the maps and the service entries of one agent.

<!-- astrona:playground:destroy -->
