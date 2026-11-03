# Find The Datapath Objects Of The probe Pod

The `probe` pod in `starfleet` receives traffic from `shuttle`. Before you change any policy, the operations team wants the datapath facts of the `probe` pod recorded: where it runs, which endpoint Cilium created and which identity the node uses for its address.

## Task

Create a ConfigMap named `node-evidence` in the `starfleet` namespace with these four keys:

- `probe_pod_ip`: the IP address of the `probe` pod.
- `probe_endpoint_id`: the endpoint ID that the Cilium agent gave to the `probe` pod.
- `probe_identity`: the numeric security identity that the IP cache of the agent maps the pod IP address to.
- `agent_pod`: the name of the Cilium agent pod that runs on the same node as the `probe` pod.

## Constraints

- Read every value from the cluster. Do not change the `probe` pod or add a policy.
- Take the identity from the IP cache of the agent on the node of the `probe` pod.

## Check your work

Run `astrona submit`. The grader compares each key with the live value from Kubernetes.
