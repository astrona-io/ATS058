# Add Twenty Services And Read Them In The Service Map

The `probe` pods serve requests on port 8080. The platform team wants to see that Cilium adds one frontend entry to the service map for each new Service, and that a new Service works without any rule being rewritten on the nodes.

## Task

1. Create twenty `ClusterIP` Services in the `starfleet` namespace named `bench-01` to `bench-20`. Each one selects the pods labelled `app: probe`, listens on port 80 and forwards to the target port 8080.
2. Confirm that the cluster IP of every new Service is a frontend in the service map of the Cilium agent.
3. Confirm that the `shuttle` pod reaches the `probe` pods through `bench-20`.
4. Record the numbers in a ConfigMap named `bench-evidence` in `starfleet`:

| Key | Value |
| --- | --- |
| `services_created` | The number of Services you created |
| `frontends_in_map` | The number of those cluster IPs that you found in the map |

## Constraints

- Create the Services with a loop, not by hand.
- Count the frontends from the agent output, not from the number of Services.

## Check your work

Run `astrona submit`. The grader lists the map of every agent and sends a request through `bench-20`.
