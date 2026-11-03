---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# eBPF Programs, Hooks And Maps

Cilium does its networking work in the Linux kernel with eBPF programs. If you do not know what such a program is, where it runs and where it keeps data, every later Cilium topic stays a black box. This module explains the building blocks: the program, the verifier that checks it, the hooks where it runs and the maps where it keeps state.

The module has four parts. The first part follows an eBPF program from source code to the kernel and explains what the verifier does and does not prove. The second part covers the hooks Cilium uses, the map types and the maps that hold Service, endpoint and policy state, and it shows you the real contents of those maps. The third part covers program types, tail calls, pinned maps and `bpftool`. The fourth part covers kernel requirements, BTF and how the agent builds and loads the programs.

## Learning objectives

After this module you can:

- Describe how an eBPF program is compiled, loaded with the `bpf()` system call, verified and attached.
- State what the verifier guarantees and what it does not guarantee.
- Name the hooks Cilium uses (tc, XDP, socket address hooks) and what each one can see.
- Explain what a map is and why the Cilium agent writes maps that programs read.
- List the BPF maps of a Cilium agent and read the service map for a Kubernetes Service.
- Name the program types that Cilium uses and explain what a tail call and a pinned map are.
- List loaded programs and maps with `bpftool`.
- Explain what BTF and CO-RE are and how the agent compiles and loads the datapath for a node.

## Before you start

You need basic Kubernetes knowledge: pods, Services, namespaces and `kubectl`. No eBPF or C knowledge is needed.

The playground is a two-node `kind` cluster with Cilium installed and Hubble Relay enabled. It runs the example application: a `probe` Deployment and Service in `starfleet`, a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. You run commands as the cluster administrator, and `kubectl` already points at the playground. Launch it now and keep it open while you read:

<!-- astrona:playground -->
