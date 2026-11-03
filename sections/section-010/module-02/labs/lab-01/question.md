# Allow One Client With A CiliumNetworkPolicy

Two clients call the `probe` Service. The `shuttle` pod in `starfleet` must keep working. The `drifter` pod in `outpost` must be blocked. Today both succeed because no policy selects the `probe` pods.

## Task

1. Create a `CiliumNetworkPolicy` in the `starfleet` namespace that selects the pods labelled `app: probe` and allows ingress only from pods labelled `app: shuttle` to TCP port 8080.
2. Read the numeric security identity of the `shuttle` pod and store it in a ConfigMap named `identity-evidence` in `starfleet`, in the key `shuttle_identity`.

## Constraints

- The rule must use the pod port, not the Service port.
- Do not add a rule for the `outpost` namespace.
- Read the identity from the cluster.

## Check your work

Run `astrona submit`. The grader sends a request from each client and compares the identity in the ConfigMap with the identity of the `shuttle` endpoint.
