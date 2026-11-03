# Solution

## Step 1: Read the policy

```sh
kubectl -n starfleet get ciliumnetworkpolicy probe-ingress -o yaml
```

The rule allows TCP port 80. The `probe` Service listens on port 80, but it forwards to the container port 8080, and policy is checked after that translation. Packets arrive at the pod on 8080, so no rule matches them.

## Step 2: Fix the port

Replace the port in place. The path is the first port of the first rule:

```sh
kubectl -n starfleet patch ciliumnetworkpolicy probe-ingress --type=json \
  -p '[{"op":"replace","path":"/spec/ingress/0/toPorts/0/ports/0/port","value":"8080"}]'
```

## Step 3: Check both clients

Wait a few seconds for the agent to update the policy map, then run:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/status/200
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/status/200
```

The first request succeeds and the second one stops after five seconds.

## Step 4: Collect the evidence

```sh
SHUTTLE_POD=$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[0].metadata.name}')
DRIFTER_POD=$(kubectl -n outpost get pods -l app=drifter -o jsonpath='{.items[0].metadata.name}')
PROBE_POD=$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}')
PROBE_IP=$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.podIP}')
kubectl -n starfleet get ciliumendpoint "$SHUTTLE_POD" -o jsonpath='{.status.identity.id}{"\n"}'
kubectl -n outpost get ciliumendpoint "$DRIFTER_POD" -o jsonpath='{.status.identity.id}{"\n"}'
kubectl -n starfleet get ciliumendpoint "$PROBE_POD" -o jsonpath='{.status.id}{"\n"}'
```

## Step 5: Record the evidence

Replace the three placeholders with the numbers printed above:

```sh
kubectl -n starfleet create configmap capstone-evidence \
  --from-literal=shuttle_identity=<SHUTTLE_IDENTITY> \
  --from-literal=drifter_identity=<DRIFTER_IDENTITY> \
  --from-literal=probe_endpoint_id=<PROBE_ENDPOINT_ID> \
  --from-literal=probe_backend="${PROBE_IP}:8080"
```

Then run `astrona submit`.
