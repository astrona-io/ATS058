#!/usr/bin/env bash
# No kube-proxy Service chain is left in the iptables rules of any node.
set -uo pipefail
fail=0
for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
  rules="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- iptables-save 2>&1)" || { echo "FAIL: iptables-save failed in ${agent}"; exit 1; }
  count="$(grep -c 'KUBE-SVC' <<<"$rules" || true)"
  if [ "${count:-0}" -ne 0 ]; then
    echo "FAIL: ${agent} node still has ${count} KUBE-SVC rules"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "PASS: no KUBE-SVC rules remain on any node"
exit "$fail"
