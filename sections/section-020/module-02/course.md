---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Observability, Safety And Live Updates

An eBPF datapath is useful in operation only if you can see what it does and change it without an outage. This module covers the two operational benefits: Hubble, which reads events from the same programs that forward packets, and the way the kernel and the Cilium agent keep traffic running while programs and maps change.

The module has four parts. The first part explains how Hubble and Hubble Relay produce flows, how to enable them on a running cluster and how to read a forwarded and a dropped flow. The second part explains what protects the node from a faulty program, how programs are replaced while traffic flows, and what happens to the datapath when the agent restarts. The third part covers Hubble metrics, the Hubble UI and Layer 7 visibility. The fourth part covers the security benefits: identity-based policy and transparent encryption.

## Learning objectives

After this module you can:

- Name the parts of Hubble (the server in the agent, Hubble Relay, the CLI) and state what each one does.
- Enable Hubble and Hubble Relay on a running Cilium release with Helm.
- Read a flow: source, destination, verdict and drop reason.
- Explain why the verifier and the absence of kernel modules protect the node.
- Describe what keeps running when the Cilium agent restarts and what stops being updated.
- Enable Hubble metrics and the Hubble UI and explain when flows show Layer 7 data.
- Name the security benefits of identity-based policy and explain WireGuard and IPsec encryption.

## Before you start

You need to know what a Cilium agent, an eBPF map and a network policy are. You need basic `helm` and `kubectl` knowledge.

The playground is a two-node `kind` cluster with Cilium installed. Hubble is switched off at the start, because you enable it during the first part. The example application runs in it: a `probe` Deployment and Service in `starfleet`, a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. You run commands as the cluster administrator, and `kubectl` already points at the playground. Launch it now and keep it open while you read:

<!-- astrona:playground -->
