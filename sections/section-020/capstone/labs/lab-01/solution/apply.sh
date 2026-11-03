#!/usr/bin/env bash
# Reference solution.
set -euo pipefail
helm repo add cilium https://helm.cilium.io/ >/dev/null 2>&1 || true
helm repo update >/dev/null
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set hubble.enabled=true --set hubble.relay.enabled=true --wait --timeout 300s
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl -n kube-system rollout status deployment/hubble-relay --timeout=300s
for number in $(seq 1 10); do
  name="bench-$(printf '%02d' "$number")"
  kubectl -n starfleet create service clusterip "$name" --tcp=80:8080 --dry-run=client -o yaml \
    | kubectl set selector --local -f - app=probe -o yaml \
    | kubectl apply -f -
done
sleep 10
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://bench-10.starfleet.svc/status/200
probe_pod="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}')"
kubectl -n starfleet create configmap capstone-evidence \
  --from-literal=frontends_in_map=10 --from-literal=hubble_verdict=FORWARDED \
  --from-literal=destination_pod="$probe_pod" --from-literal=relay_service=hubble-relay \
  --dry-run=client -o yaml | kubectl apply -f -
