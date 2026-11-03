# Solution

## Step 1: Find the pod, its address and its node

The `-o wide` output shows the pod IP in the `IP` column and the node in the `NODE` column:

```sh
kubectl -n starfleet get pods -l app=probe -o wide
```

Store the values in shell variables so the later commands stay short:

```sh
PROBE_POD=$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}')
PROBE_IP=$(kubectl -n starfleet get pod "$PROBE_POD" -o jsonpath='{.status.podIP}')
PROBE_NODE=$(kubectl -n starfleet get pod "$PROBE_POD" -o jsonpath='{.spec.nodeName}')
```

## Step 2: Find the agent on that node

A field selector returns only the agent pod of one node:

```sh
AGENT_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium --field-selector spec.nodeName="$PROBE_NODE" -o jsonpath='{.items[0].metadata.name}')
echo "$AGENT_POD"
```

## Step 3: Read the endpoint ID

The endpoint list of that agent has one row per local endpoint. Find the row with the pod address. The first column is the endpoint ID:

```sh
kubectl -n kube-system exec "$AGENT_POD" -c cilium-agent -- cilium-dbg endpoint list
```

The same number is in the `CiliumEndpoint` object:

```sh
ENDPOINT_ID=$(kubectl -n starfleet get ciliumendpoint "$PROBE_POD" -o jsonpath='{.status.id}')
```

## Step 4: Read the identity from the IP cache

```sh
kubectl -n kube-system exec "$AGENT_POD" -c cilium-agent -- cilium-dbg bpf ipcache get "$PROBE_IP"
```

The result shows the identity number for the address. Set it as a variable, for example `IDENTITY=<number>`. The number must also match the identity column of the endpoint list.

## Step 5: Record the evidence

```sh
kubectl -n starfleet create configmap node-evidence \
  --from-literal=probe_pod_ip="$PROBE_IP" \
  --from-literal=probe_endpoint_id="$ENDPOINT_ID" \
  --from-literal=probe_identity="$IDENTITY" \
  --from-literal=agent_pod="$AGENT_POD"
```

Then run `astrona submit`.
