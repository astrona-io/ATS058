---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Hubble CLI, Tetragon, Service Mesh And The eBPF Ecosystem

Cilium is one use of eBPF, and the benefits of eBPF reach further than packet forwarding. This module shows how to query Hubble flows precisely from the command line, how Cilium adds Layer 7 features on a per-node Envoy proxy, and which other eBPF projects exist next to Cilium. It places the Cilium datapath in the larger picture of eBPF tools.

The module has four parts. The first part covers the `hubble observe` filters. The second part covers the structure of a flow and how to process it as JSON. The third part covers the Cilium service mesh features that run without sidecar proxies. The fourth part covers Tetragon and other eBPF projects.

## Learning objectives

After this module you can:

- Select flows with the filters of `hubble observe`, such as the verdict, the pod, the port and the protocol.
- Read the fields of a flow in JSON output and extract them with a command line tool.
- Explain how Cilium provides Ingress, Gateway API and Layer 7 policy with a per-node Envoy proxy.
- State what Tetragon observes and enforces and how it differs from the Cilium datapath.
- Name other projects that use eBPF and the problem each one solves.

## Before you start

You need to know what a Hubble flow is and how Hubble Relay collects flows. The module before this one covers both.

The playground is a two-node `kind` cluster with Cilium installed and Hubble and Hubble Relay already enabled. It runs the example application: a `probe` Deployment and Service in `starfleet`, a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. A policy allows only `shuttle` to reach `probe`. You run commands as the cluster administrator, and `kubectl` already points at the playground. Launch it now and keep it open while you read:

<!-- astrona:playground -->
