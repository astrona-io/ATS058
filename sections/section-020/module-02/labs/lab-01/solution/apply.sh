#!/usr/bin/env bash
# Reference solution.
set -euo pipefail
helm repo add cilium https://helm.cilium.io/ >/dev/null 2>&1 || true
helm repo update >/dev/null
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set hubble.enabled=true --set hubble.relay.enabled=true --wait --timeout 300s
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl -n kube-system rollout status deployment/hubble-relay --timeout=300s
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/status/200 || true
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/status/200 || true
kubectl -n starfleet create configmap flow-evidence \
  --from-literal=forwarded_client=shuttle --from-literal=dropped_client=drifter \
  --from-literal=drop_reason="Policy denied" --dry-run=client -o yaml | kubectl apply -f -
