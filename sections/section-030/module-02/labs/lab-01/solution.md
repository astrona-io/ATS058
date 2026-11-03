# Solution

## Step 1: Upgrade the release

Cilium needs the address of the API server, because without kube-proxy it cannot use the in-cluster `kubernetes` Service to reach it. In a `kind` cluster the control plane node name resolves to its address:

```sh
API_HOST=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set kubeProxyReplacement=true --set k8sServiceHost="$API_HOST" --set k8sServicePort=6443 \
  --wait --timeout 300s
```

## Step 2: Restart the operator and the agents

The agents read their settings when they start, so restart them and wait:

```sh
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

Check that an agent reports the replacement. The status line should say `True`:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep KubeProxyReplacement
```

## Step 3: Delete kube-proxy

```sh
kubectl -n kube-system delete daemonset kube-proxy
kubectl -n kube-system delete configmap kube-proxy --ignore-not-found
```

## Step 4: Remove the old rules

Deleting kube-proxy does not delete the rules it wrote. Save every table, drop the lines that contain `KUBE`, and load the rest again. Run it in each agent pod, because the agents share the network namespace of their node:

```sh
for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
  kubectl -n kube-system exec "$agent" -c cilium-agent -- sh -c 'iptables-save | grep -v KUBE | iptables-restore'
done
```

## Step 5: Check the result

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/status/200
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg bpf lb list
```

Then run `astrona submit`.
