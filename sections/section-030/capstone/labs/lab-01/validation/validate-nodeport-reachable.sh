#!/usr/bin/env bash
# A real request from drifter (outpost) to port 30080 on each node address must return HTTP 200.
set -uo pipefail
fail=0
for node_ip in $(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'); do
  ok=0
  for attempt in 1 2 3 4 5 6 7 8; do
    code="$(kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' "http://${node_ip}:30080/status/200" 2>/dev/null || true)"
    if [ "$code" = "200" ]; then ok=1; break; fi
    sleep 3
  done
  if [ "$ok" -ne 1 ]; then echo "FAIL: ${node_ip}:30080 did not return HTTP 200 (last code: '${code}')"; fail=1; fi
done
[ "$fail" -eq 0 ] && echo "PASS: the NodePort answers on every node"
exit "$fail"
