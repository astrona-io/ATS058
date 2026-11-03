#!/usr/bin/env bash
# Port 30080 must be a frontend in the service map of every agent.
set -uo pipefail
fail=0
for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
  if ! kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg bpf lb list 2>/dev/null | grep -q ':30080'; then
    echo "FAIL: ${agent} has no frontend on port 30080"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "PASS: port 30080 is a frontend in every agent"
exit "$fail"
