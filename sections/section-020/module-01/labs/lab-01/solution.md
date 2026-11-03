# Solution

## Step 1: Create the Services in a loop

`kubectl create service clusterip` writes the Service object, `kubectl set selector --local` adds the selector `app=probe` and `kubectl apply` creates it:

```sh
for number in $(seq 1 20); do
  name="bench-$(printf '%02d' "$number")"
  kubectl -n starfleet create service clusterip "$name" --tcp=80:8080 --dry-run=client -o yaml \
    | kubectl set selector --local -f - app=probe -o yaml \
    | kubectl apply -f -
done
```

Check that twenty Services exist:

```sh
kubectl -n starfleet get services | grep -c '^bench-'
```

## Step 2: Read the map

Save the name of an agent pod and print the frontends and backends:

```sh
AGENT=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$AGENT" -c cilium-agent -- cilium-dbg bpf lb list
```

Read the cluster IPs of the new Services:

```sh
kubectl -n starfleet get services -o custom-columns=NAME:.metadata.name,IP:.spec.clusterIP | grep '^bench-'
```

Count how many of these addresses appear in the map with port 80. Wait a few seconds and repeat the listing if the count is not yet twenty, because the agent updates the map after it sees each Service.

## Step 3: Send a request through the last Service

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://bench-20.starfleet.svc/status/200
```

## Step 4: Record the numbers

Use the count that you found, which should be 20:

```sh
kubectl -n starfleet create configmap bench-evidence \
  --from-literal=services_created=20 \
  --from-literal=frontends_in_map=<COUNT>
```

Then run `astrona submit`.
