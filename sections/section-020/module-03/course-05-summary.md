---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Summary

The Hubble command line selects flows from one agent or from the whole cluster through Hubble Relay. Filters narrow the result by namespace, pod, verdict, protocol, port and event type. JSON output gives every flow named fields, such as the verdict, the drop reason, the source and destination endpoints with their identities, and the ports. A script can extract and count those fields, but a flow is not a request, because one request creates several flows.

Cilium provides Layer 7 features with one Envoy proxy on each node. The eBPF programs send only the traffic that needs Layer 7 handling to that proxy, and they forward the rest in the kernel. Layer 7 policy, Ingress and Gateway API use the proxy, so pods need no sidecar container.

Other projects use the same kernel mechanism for other jobs. Tetragon observes and can enforce rules on processes, files and system calls, using a TracingPolicy. Falco, Pixie, Katran and the tracing tools use eBPF for detection, tracing and load balancing. Cilium covers the network, and these tools cover what happens inside the node.

Key facts:

- `hubble observe` in an agent shows only the flows of that node.
- The default text output can change between releases, so scripts use JSON.
- Layer 7 data appears only for traffic that a policy sends through Envoy.
- Tetragon is installed separately from Cilium and is configured with a TracingPolicy.

<!-- astrona:playground:destroy -->
