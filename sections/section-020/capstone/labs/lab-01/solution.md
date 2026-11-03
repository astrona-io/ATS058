# Solution

## Step 1: Enable Hubble and Hubble Relay

```sh
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set hubble.enabled=true --set hubble.relay.enabled=true --wait --timeout 300s
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl -n kube-system rollout status deployment/hubble-relay --timeout=300s
```

## Step 2: Create the Services

```sh
for number in $(seq 1 10); do
  name="bench-$(printf '%02d' "$number")"
  kubectl -n starfleet create service clusterip "$name" --tcp=80:8080 --dry-run=client -o yaml \
    | kubectl set selector --local -f - app=probe -o yaml \
    | kubectl apply -f -
done
```

## Step 3: Read the service map

```sh
AGENT=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$AGENT" -c cilium-agent -- cilium-dbg bpf lb list
kubectl -n starfleet get services -o custom-columns=NAME:.metadata.name,IP:.spec.clusterIP | grep '^bench-'
```

Count the cluster IPs that appear in the map with port 80. Wait a few seconds and list again if some are missing.

## Step 4: Send a request and read the flow

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://bench-10.starfleet.svc/status/200
kubectl -n starfleet get pods -l app=probe -o wide
```

Run `hubble observe` in the agent on the node of the `probe` pod and look for the FORWARDED line from the `shuttle` pod. Replace `<AGENT>` with that agent pod name:

```sh
kubectl -n kube-system exec <AGENT> -c cilium-agent -- hubble observe --namespace starfleet --last 50
```

## Step 5: Record the evidence

Find the Relay Service name with `kubectl -n kube-system get services`, then record the values:

```sh
PROBE_POD=$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}')
kubectl -n starfleet create configmap capstone-evidence \
  --from-literal=frontends_in_map=10 \
  --from-literal=hubble_verdict=FORWARDED \
  --from-literal=destination_pod="$PROBE_POD" \
  --from-literal=relay_service=hubble-relay
```

Then run `astrona submit`.
