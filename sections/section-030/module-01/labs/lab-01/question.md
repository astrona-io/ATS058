# Find The kube-proxy Rules Of The probe Service

The cluster uses kube-proxy in iptables mode, and the `probe` Deployment runs three pods. The platform team wants to know which iptables chain handles the `probe` Service and how many backend chains it has.

## Task

Read the NAT rules of a node and record the result in a ConfigMap named `iptables-evidence` in `starfleet`:

| Key | Value |
| --- | --- |
| `probe_cluster_ip` | The cluster IP of the `probe` Service |
| `service_chain` | The name of the `KUBE-SVC-` chain for the `probe` Service port `http` |
| `backend_chain_count` | The number of `KUBE-SEP-` chains that this Service chain jumps to |

## Constraints

- Read the rules from the cluster. Do not guess the chain name: it is derived from the Service and changes between clusters.
- Do not change the Service or the Deployment.

## Check your work

Run `astrona submit`. The grader reads the rules again and compares them with the ConfigMap.
