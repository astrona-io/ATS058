# Find A Dropped Flow With Hubble Filters

Hubble and Hubble Relay already run in the cluster. A policy named `probe-from-shuttle` allows only the `shuttle` pod to reach the `probe` pods. The team suspects that a client from another namespace is being denied, and wants the facts from Hubble, selected with filters.

## Task

1. Send a request from the `drifter` pod in `outpost` to the `probe` Service.
2. Use `hubble observe` with filters to select only the dropped flows from `drifter` to `probe`.
3. Read the destination port and the protocol of that flow, and read the security identity of the `drifter` pod from its CiliumEndpoint.
4. Record the result in a ConfigMap named `flow-filter-evidence` in `starfleet`:

| Key | Value |
| --- | --- |
| `dropped_client` | The name of the client whose flow is dropped |
| `destination_port` | The destination port of the dropped flow |
| `protocol` | The protocol of the dropped flow |
| `source_identity` | The numeric security identity of the `drifter` pod |

## Constraints

- Do not change or delete the policy.
- Do not change the Cilium release.

## Check your work

Run `astrona submit`. The grader sends its own request and reads the flows and the CiliumEndpoint.
