# Read The Service Datapath From The Agent

The `probe` Service in the `starfleet` namespace is reachable at its cluster IP. The platform team wants proof that Cilium programmed this Service into an eBPF map and that the map, not only the Kubernetes object, holds the backend that receives the traffic.

## Task

Collect four facts from the running cluster and record them in a ConfigMap named `datapath-evidence` in the `starfleet` namespace.

| Key | Value |
| --- | --- |
| `probe_cluster_ip` | The cluster IP of the `probe` Service |
| `probe_backend` | The address and port of a `probe` pod in the form `<pod IP>:8080` |
| `agent_pod` | The name of a Cilium agent pod in `kube-system` |
| `service_map` | The name of the IPv4 service map that the agent lists |

## Constraints

- Read every value from the cluster. Do not type a value you have not read.
- The ConfigMap must be in the `starfleet` namespace.
- You may use any `probe` pod and any agent pod.

## Check your work

Run `astrona submit` after you create the ConfigMap. The grader reads the ConfigMap and compares each value with the cluster and with the agent.
