#!/usr/bin/env bash
# Reference solution.
set -euo pipefail
helm repo add cilium https://helm.cilium.io/ >/dev/null 2>&1 || true
helm repo update >/dev/null
api_host="$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')"
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set bpf.masquerade=true --set kubeProxyReplacement=true \
  --set k8sServiceHost="$api_host" --set k8sServicePort=6443 \
  --wait --timeout 300s
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
agents="$(kubectl -n kube-system get pods -l k8s-app=cilium --no-headers | wc -l | tr -d ' ')"
kubectl -n starfleet create configmap masquerade-evidence \
  --from-literal=masquerade_mode=BPF --from-literal=agent_count="$agents" \
  --dry-run=client -o yaml | kubectl apply -f -
