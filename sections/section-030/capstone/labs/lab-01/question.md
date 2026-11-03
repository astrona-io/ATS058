# Capstone: Migrate To kube-proxy Replacement And Keep A NodePort Working

The cluster uses kube-proxy. The Service `probe-nodeport` in `starfleet` exposes the `probe` pods on node port 30080, and clients depend on it. The team will move Service handling to Cilium and must keep the NodePort working on every node.

## Task

1. Enable kube-proxy replacement on the existing Cilium release with the API server host and port set. Keep the other values.
2. Restart the agents, delete the `kube-proxy` DaemonSet and ConfigMap, and remove the kube-proxy iptables rules on every node.
3. Show that the `drifter` pod in `outpost` reaches the `probe` pods through port 30080 on every node address.
4. Show that every agent lists port 30080 in its service map.
5. Record the evidence in a ConfigMap named `capstone-evidence` in `starfleet`:

| Key | Value |
| --- | --- |
| `kube_proxy_replacement` | The value that the agent status reports for `KubeProxyReplacement` |
| `nodeport` | The node port of `probe-nodeport` |
| `probe_backends` | The number of `probe` pods |

## Constraints

- Do not change the Service `probe-nodeport`.
- Remove only the kube-proxy rules.
- The API server listens on port 6443 on the control plane node.

## Check your work

Run `astrona submit`.
