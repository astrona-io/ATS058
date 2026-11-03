---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# Inspecting The Cilium Datapath On A Node

The earlier modules explain what the Cilium datapath is made of. When something breaks, you must be able to look at it. This module teaches a fixed order of commands that takes you from a Kubernetes pod to the endpoint, the identity, the IP cache entry, the policy map, the connection tracking entry and the packet events on one node.

The module has four parts. The first part reads the health and the endpoints of an agent. The second part follows identities and the IP cache. The third part reads policy and connection tracking state. The fourth part watches live events with `cilium-dbg monitor` and checks the loaded programs.

## Learning objectives

After this module you can:

- Read the datapath health, the endpoint list and the endpoint details of one agent.
- Find the agent that runs on the node of a given pod.
- Translate a pod IP address to a security identity with the IP cache and the identity list.
- Read the policy map and the connection tracking table of an endpoint.
- Watch drop and trace events live and relate them to a policy.

## Before you start

You need to know what an endpoint, a security identity and a BPF map are, and how to run a command in an agent pod with `kubectl exec`.

The playground is a two-node `kind` cluster with Cilium installed and Hubble Relay enabled. It runs the example application: a `probe` Deployment and Service in `starfleet`, a `shuttle` client in `starfleet` and a `drifter` client in `outpost`. You run commands as the cluster administrator, and `kubectl` already points at the playground. Launch it now and keep it open while you read:

<!-- astrona:playground -->
