# Enable Hubble And Observe A Forwarded And A Dropped Flow

The cluster runs Cilium without Hubble. A policy named `probe-from-shuttle` allows only the `shuttle` pod to reach the `probe` pods. The team wants to see both outcomes as flows: the allowed request and the denied request.

## Task

1. Enable Hubble and Hubble Relay on the existing Cilium release. Keep the other Helm values.
2. Send a request from the `shuttle` pod in `starfleet` and one from the `drifter` pod in `outpost` to the `probe` Service.
3. Use Hubble to find the forwarded flow and the dropped flow.
4. Record the result in a ConfigMap named `flow-evidence` in `starfleet`:

| Key | Value |
| --- | --- |
| `forwarded_client` | The client whose flow has the verdict FORWARDED |
| `dropped_client` | The client whose flow has the verdict DROPPED |
| `drop_reason` | The drop reason that Hubble prints for that flow |

## Constraints

- Do not change or delete the policy.
- Use `--reuse-values` so the earlier Cilium settings stay.

## Check your work

Run `astrona submit`. The grader sends its own requests and reads the flows with `hubble observe`.
