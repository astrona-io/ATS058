# Solution

## Step 1: Upgrade the release

eBPF masquerading needs NodePort handling in Cilium, so enable the replacement too. Without kube-proxy as a helper for the API server address, Cilium needs the host and port of the API server. In a `kind` cluster the control plane node name resolves to its address:

```sh
API_HOST=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set bpf.masquerade=true --set kubeProxyReplacement=true \
  --set k8sServiceHost="$API_HOST" --set k8sServicePort=6443 \
  --wait --timeout 300s
```

## Step 2: Restart the operator and the agents

The agents read their settings when they start:

```sh
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

## Step 3: Check the mode and the Service

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep Masquerading
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc/status/200
```

The first line should name the `BPF` mode. The request should print `200`.

## Step 4: Record the evidence

```sh
AGENTS=$(kubectl -n kube-system get pods -l k8s-app=cilium --no-headers | wc -l | tr -d ' ')
kubectl -n starfleet create configmap masquerade-evidence \
  --from-literal=masquerade_mode=BPF --from-literal=agent_count="$AGENTS"
```

Then run `astrona submit`.
