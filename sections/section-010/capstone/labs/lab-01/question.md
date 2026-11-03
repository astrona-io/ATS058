# Capstone: Repair A Policy And Prove The Datapath State

The `shuttle` pod in `starfleet` can no longer reach the `probe` Service since a policy named `probe-ingress` was added. The author meant to allow `shuttle`. The `drifter` pod in `outpost` must stay blocked.

## Task

1. Find why `shuttle` is blocked and fix the existing policy `probe-ingress`. Do not delete it and do not add a new policy.
2. Verify that `shuttle` reaches the `probe` Service and that `drifter` does not.
3. Record the evidence in a ConfigMap named `capstone-evidence` in `starfleet` with these keys:

| Key | Value |
| --- | --- |
| `shuttle_identity` | Numeric security identity of the `shuttle` pod |
| `drifter_identity` | Numeric security identity of the `drifter` pod |
| `probe_endpoint_id` | Endpoint ID of the `probe` pod, from its `CiliumEndpoint` |
| `probe_backend` | `<pod IP>:8080` of the `probe` pod |

## Constraints

- Read every value from the cluster.
- The policy must keep `shuttle` as its only allowed source.
- There is one `probe` pod.

## Check your work

Run `astrona submit`. The grader sends requests from both clients and compares the ConfigMap with the cluster.
