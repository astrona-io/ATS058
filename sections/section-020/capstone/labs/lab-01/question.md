# Capstone: Add Services And Prove The Flow With Hubble

The cluster runs Cilium without Hubble. The team plans to add ten Services for a new feature and wants proof of two things: each Service becomes a frontend in the service map, and a request through a new Service is visible as a forwarded flow.

## Task

1. Enable Hubble and Hubble Relay on the existing Cilium release and keep the other Helm values.
2. Create ten `ClusterIP` Services in `starfleet` named `bench-01` to `bench-10`. Each one selects `app: probe`, uses port 80 and forwards to the target port 8080.
3. Confirm that all ten cluster IPs are frontends in the service map.
4. Send a request from the `shuttle` pod to `http://bench-10.starfleet.svc/status/200` and find the FORWARDED flow with Hubble.
5. Record the evidence in a ConfigMap named `capstone-evidence` in `starfleet`:

| Key | Value |
| --- | --- |
| `frontends_in_map` | Number of the ten cluster IPs found in the map |
| `hubble_verdict` | Verdict of the flow from `shuttle` to the `probe` pod |
| `destination_pod` | Name of the `probe` pod that Hubble shows as the destination |
| `relay_service` | Name of the Hubble Relay Service in `kube-system` |

## Constraints

- Read every value from the cluster.
- Keep the earlier Helm values with `--reuse-values`.

## Check your work

Run `astrona submit`.
