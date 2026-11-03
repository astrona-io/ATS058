# Solution

The task needs four values. Two come from Kubernetes objects and two come from the Cilium agent.

## Step 1: Find the agent pod

The agents run as the `cilium` DaemonSet in `kube-system`. Save the name of the first agent pod:

```sh
AGENT=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
echo "$AGENT"
```

## Step 2: Read the Service and the pod

The cluster IP is a field of the Service. The pod IP is a field of the pod status:

```sh
SERVICE_IP=$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}')
POD_IP=$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.podIP}')
echo "$SERVICE_IP" "$POD_IP"
```

The container port of `probe` is 8080, so the backend is the pod IP with `:8080`.

## Step 3: Find the service map name

List the maps that the agent has open and keep the IPv4 service map:

```sh
kubectl -n kube-system exec "$AGENT" -c cilium-agent -- cilium-dbg map list
```

Find the row whose name contains `lb4_services` and copy the name from that row.

## Step 4: Confirm the map holds the Service

Print the frontends and backends and look for the cluster IP with port 80 and for the pod IP with port 8080:

```sh
kubectl -n kube-system exec "$AGENT" -c cilium-agent -- cilium-dbg bpf lb list
```

## Step 5: Record the evidence

Replace `<MAP>` with the map name from step 3:

```sh
kubectl -n starfleet create configmap datapath-evidence \
  --from-literal=probe_cluster_ip="$SERVICE_IP" \
  --from-literal=probe_backend="${POD_IP}:8080" \
  --from-literal=agent_pod="$AGENT" \
  --from-literal=service_map="<MAP>"
```

Then run `astrona submit`.
