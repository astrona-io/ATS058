# Solution

## Step 1: Save the policy

The Service listens on port 80 and forwards to the container port 8080. Policy sees the pod port, so the rule names 8080. Save this as `ciliumnetworkpolicy-probe.yaml`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-from-shuttle
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP
```

Apply it:

```sh
kubectl apply -f ciliumnetworkpolicy-probe.yaml
```

Then check that the agent accepted it. The `VALID` column should show `True`:

```sh
kubectl -n starfleet get ciliumnetworkpolicy probe-from-shuttle
```

## Step 2: Check both clients

The request from `shuttle` still succeeds. The request from `drifter` has no matching rule and stops after five seconds:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/status/200
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/status/200
```

## Step 3: Record the identity

The `CiliumEndpoint` of a pod has the same name as the pod:

```sh
SHUTTLE_POD=$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[0].metadata.name}')
IDENTITY=$(kubectl -n starfleet get ciliumendpoint "$SHUTTLE_POD" -o jsonpath='{.status.identity.id}')
kubectl -n starfleet create configmap identity-evidence --from-literal=shuttle_identity="$IDENTITY"
```

Then run `astrona submit`.
