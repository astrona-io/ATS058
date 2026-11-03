# Solution

## Step 1: Enable the replacement

```sh
API_HOST=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set kubeProxyReplacement=true --set k8sServiceHost="$API_HOST" --set k8sServicePort=6443 \
  --wait --timeout 300s
```

## Step 2: Restart and clean up

```sh
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl -n kube-system delete daemonset kube-proxy
kubectl -n kube-system delete configmap kube-proxy --ignore-not-found
```

Remove the leftover rules in each agent pod:

```sh
for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
  kubectl -n kube-system exec "$agent" -c cilium-agent -- sh -c 'iptables-save | grep -v KUBE | iptables-restore'
done
```

## Step 3: Test the node port on every node

List the node addresses:

```sh
kubectl get nodes -o wide
```

Replace `<NODE_IP>` with each INTERNAL-IP value in turn:

```sh
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://<NODE_IP>:30080/status/200
```

## Step 4: Read the map

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg bpf lb list
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep KubeProxyReplacement
```

Look for entries with port 30080. The status line shows the value for the evidence.

## Step 5: Record the evidence

Replace `<STATUS>` with the word that the status line shows after `KubeProxyReplacement:`:

```sh
kubectl -n starfleet create configmap capstone-evidence \
  --from-literal=kube_proxy_replacement=<STATUS> \
  --from-literal=nodeport=30080 \
  --from-literal=probe_backends=3
```

Then run `astrona submit`.
