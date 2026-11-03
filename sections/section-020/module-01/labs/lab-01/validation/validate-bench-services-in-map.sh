#!/usr/bin/env bash
# Every bench Service cluster IP must be a frontend in the service map of every Cilium agent.
set -uo pipefail
fail=0
for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    map="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg bpf lb list 2>/dev/null || true)"
    missing=0
    for number in $(seq 1 20); do
      ip="$(kubectl -n starfleet get service "bench-$(printf '%02d' "$number")" -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)"
      if [ -z "$ip" ] || ! grep -q "${ip}:80" <<<"$map"; then missing=$((missing + 1)); fi
    done
    [ "$missing" -eq 0 ] && break
    sleep 3
  done
  if [ "$missing" -ne 0 ]; then
    echo "FAIL: $missing bench Services are not in the service map of $agent"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "PASS: all bench Services are frontends in every agent"
exit "$fail"
