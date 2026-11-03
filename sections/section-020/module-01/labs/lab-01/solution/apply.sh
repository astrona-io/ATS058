#!/usr/bin/env bash
# Reference solution.
set -euo pipefail
for number in $(seq 1 20); do
  name="bench-$(printf '%02d' "$number")"
  kubectl -n starfleet create service clusterip "$name" --tcp=80:8080 --dry-run=client -o yaml \
    | kubectl set selector --local -f - app=probe -o yaml \
    | kubectl apply -f -
done
agent="$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')"
found=0
for attempt in $(seq 1 20); do
  map="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg bpf lb list)"
  found=0
  for number in $(seq 1 20); do
    ip="$(kubectl -n starfleet get service "bench-$(printf '%02d' "$number")" -o jsonpath='{.spec.clusterIP}')"
    if grep -q "${ip}:80" <<<"$map"; then found=$((found + 1)); fi
  done
  [ "$found" -eq 20 ] && break
  sleep 3
done
kubectl -n starfleet create configmap bench-evidence --from-literal=services_created=20 --from-literal=frontends_in_map="$found" --dry-run=client -o yaml | kubectl apply -f -
