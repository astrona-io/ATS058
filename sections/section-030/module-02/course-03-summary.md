---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Summary

With `kubeProxyReplacement` set to true, Cilium handles ClusterIP, NodePort, ExternalIPs and LoadBalancer Services. A pod that connects to a cluster IP is translated at the socket. External traffic to a node port is translated by a tc or XDP program that looks up the service map, and an eBPF connection tracking map remembers the translation. By default, the receiving node rewrites the source address so the reply returns through it. Direct server return mode lets the backend node reply to the client directly, when the network allows it.

The values `k8sServiceHost` and `k8sServicePort` give the agent the address of the API server. They are needed because the in-cluster `kubernetes` Service is translated by kube-proxy, and the agent must not depend on that translation to start. The mode is confirmed by the `KubeProxyReplacement` line of `cilium-dbg status` and by Services in `cilium-dbg bpf lb list`, and the agents must restart to apply the setting.

A migration upgrades the Helm release, restarts the operator and agents, verifies the mode while kube-proxy still runs, deletes the kube-proxy DaemonSet and ConfigMap, and removes the `KUBE` rules from every node. Deleting the DaemonSet does not remove its rules. Cilium may keep its own iptables chains, so the goal is that no kube-proxy rule remains.

Key facts:

- The Helm default for `kubeProxyReplacement` is false.
- Agents read the setting when they start.
- The cleanup must run on every node.
- A Service handled by Cilium appears in the map.

<!-- astrona:playground:destroy -->
