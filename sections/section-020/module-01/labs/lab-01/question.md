---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Verify An eBPF Backed Service Path

Prove the probe Service address is present in a real BPF service map.

## Starting state

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-058-lab-020-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-058-lab-020-01-01" || exit 1
node_name="astro-ats-058-lab-020-01-01-control-plane"
worker_name="astro-ats-058-lab-020-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Read the BPF service map and make a successful service request. eBPF changes implementation and visibility; it does not remove network policy, routing or resource constraints.

Record observations in `starfleet/evidence`, whose `report.json` contains the stated report. The verifier reads the live API again; invented values do not pass.

The report object uses these fields: `service_ip`, `map_has_service`, `kube_proxy_replacement`. Keep numeric values numeric and preserve arrays and nested objects returned by the API.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
