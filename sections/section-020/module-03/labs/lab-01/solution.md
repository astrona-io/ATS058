# Solution

## Step 1: Generate the flow

```sh
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/status/200
```

The request has no matching rule and stops after five seconds.

## Step 2: Select the dropped flow

Each agent shows the flows of its own node. Find the node of the `probe` pod and the agent on that node:

```sh
kubectl -n starfleet get pods -l app=probe -o wide
kubectl -n kube-system get pods -l k8s-app=cilium -o wide
```

Replace `<AGENT>` with the agent pod name and run the filtered command:

```sh
kubectl -n kube-system exec <AGENT> -c cilium-agent -- hubble observe --from-label app=drifter --to-label app=probe --verdict DROPPED --last 20
```

The line shows the drifter pod as the source, the probe pod as the destination with port 8080, the protocol TCP and the verdict DROPPED. The port is the pod port, because the Service address was translated before the policy decision.

## Step 3: Read the identity

The CiliumEndpoint of the `drifter` pod holds its numeric security identity:

```sh
kubectl -n outpost get ciliumendpoints -o jsonpath='{.items[0].status.identity.id}{"\n"}'
```

## Step 4: Record the evidence

Replace `<ID>` with the number from step 3:

```sh
kubectl -n starfleet create configmap flow-filter-evidence \
  --from-literal=dropped_client=drifter \
  --from-literal=destination_port=8080 \
  --from-literal=protocol=TCP \
  --from-literal=source_identity=<ID>
```

Then run `astrona submit`.
