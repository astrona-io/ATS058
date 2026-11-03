---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# Summary

A Cilium problem is local to a node, so the first step is to find the node of the pod and the agent that runs there. The agent status shows the health of the agent, and the endpoint list shows each endpoint with its local ID, its state, its policy enforcement and its security identity. The endpoint ID is unique only on one node, and the identity is the same everywhere.

The IP cache turns the source address of a packet into an identity. The identity list shows the labels behind each identity, and reserved identities cover the node, the outside world and endpoints that are not ready. The policy map of the destination endpoint holds the allowed identities, ports and protocols. The first policy that selects an endpoint enables enforcement in that direction, and everything that no entry allows is dropped.

Connection tracking entries let established connections skip the policy lookup, so a new policy is tested with a new connection. The event stream shows drops, traces and policy verdicts, and both `cilium-dbg monitor` and Hubble read it. Reading the endpoint, the IP cache entry, the policy map and the live events in this order explains a drop at the level where the kernel decides.

Key facts:

- `cilium-dbg` shows one node, so choose the agent of the right node.
- Address, identity, policy entry and verdict are the four steps of a decision.
- Policy is enforced on the node of the protected endpoint.
- A drop event names its reason.

<!-- astrona:playground:destroy -->
