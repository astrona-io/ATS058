#!/usr/bin/env bash
# Every probe pod IP must be a backend in the service map of every agent.
set -uo pipefail
fail=0
pod_ips="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[*].status.podIP}')"
[ -n "$pod_ips" ] || { echo "FAIL: no probe pods found"; exit 1; }
for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
  map="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg bpf lb list 2>/dev/null || true)"
  for ip in $pod_ips; do
    if ! grep -q "${ip}:8080" <<<"$map"; then echo "FAIL: ${agent} has no backend ${ip}:8080"; fail=1; fi
  done
done
[ "$fail" -eq 0 ] && echo "PASS: all probe pods are backends in every agent"
exit "$fail"
