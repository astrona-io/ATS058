---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# Summary

The Cilium agent runs as a DaemonSet, so one agent runs on every node. It watches the Kubernetes API, loads the eBPF programs on its node and writes the maps that the programs read. The operator does cluster-wide tasks, and the CNI plugin passes pod network setup requests from the container runtime to the local agent. When a pod starts, the CNI plugin creates the virtual interface and the agent creates an endpoint, attaches programs and writes map entries.

Cilium gives each set of pods with the same security-relevant labels a numeric security identity. Policy compares identities, so a rule stays valid when pods are replaced and their IP addresses change. The IP cache map translates a source address to an identity for each packet. Pods in different namespaces get different identities even when they use the same label values.

A `CiliumNetworkPolicy` or Kubernetes `NetworkPolicy` is resolved by the agent into entries in the policy map of each selected endpoint. The first policy that selects an endpoint switches it to default deny for that direction. The tc program on the pod interface looks up identity, port and protocol and returns allow or drop. Service translation happens before the policy check, so a rule names the pod port. Rules at layer 7 are handled by an Envoy proxy that the datapath redirects traffic to.

Cilium keeps shared state in custom resources such as `CiliumEndpoint`, `CiliumIdentity` and `CiliumNode`, and reads its settings from the `cilium-config` ConfigMap. The `cilium-dbg` tool in the agent pod shows one node, and the `cilium` command line interface works on the cluster.

Cilium tracks connections in its own eBPF maps, evaluates policy on the first packet of a connection and lets replies match the stored entry. Between nodes, Cilium either encapsulates packets in a tunnel or routes them natively.

Key facts:

- The agent writes maps and the programs read them.
- Identities come from labels, and a label change can change the identity.
- Policy is enforced on the node of the protected pod.
- `kubectl get ciliumendpoints` and `cilium-dbg endpoint list` show endpoints and identities.

<!-- astrona:playground:destroy -->
