# Solution

## Step 1: Enable Hubble and Hubble Relay

Hubble is part of the agent, and Hubble Relay is a separate Deployment that collects flows from all agents. Enable both with a Helm upgrade. `--reuse-values` keeps the existing settings. Use the same chart version that the cluster was installed with, which the setup script pinned:

```sh
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set hubble.enabled=true --set hubble.relay.enabled=true --wait --timeout 300s
```

Wait until the agents and the relay are ready:

```sh
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl -n kube-system rollout status deployment/hubble-relay --timeout=300s
```

## Step 2: Generate both flows

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/status/200
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/status/200
```

The second request has no matching rule and stops after five seconds.

## Step 3: Observe the flows

Each agent shows the flows of its own node. Run the command in the agent on the node of the `probe` pod, which sees the verdict of the policy. Find the node with `kubectl -n starfleet get pods -l app=probe -o wide`, then select the agent on that node:

```sh
kubectl -n kube-system get pods -l k8s-app=cilium -o wide
```

Replace `<AGENT>` with that agent pod name:

```sh
kubectl -n kube-system exec <AGENT> -c cilium-agent -- hubble observe --namespace starfleet --last 50
```

Look for a line with FORWARDED from the `shuttle` pod to the `probe` pod, and a line with DROPPED from the `drifter` pod to the `probe` pod. The drop line names the reason, which is Policy denied.

## Step 4: Record the evidence

```sh
kubectl -n starfleet create configmap flow-evidence \
  --from-literal=forwarded_client=shuttle \
  --from-literal=dropped_client=drifter \
  --from-literal=drop_reason="Policy denied"
```

Then run `astrona submit`.
