#!/usr/bin/env bash
# The filter by label and verdict selects the dropped flow from drifter to probe on port 8080.
set -uo pipefail
kubectl -n outpost exec deploy/drifter -- curl -s -m 4 -o /dev/null http://probe.starfleet.svc/status/200 >/dev/null 2>&1 || true
for attempt in 1 2 3 4 5 6 7 8; do
  for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
    flows="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- hubble observe --from-label app=drifter --to-label app=probe --verdict DROPPED --to-port 8080 --last 50 2>/dev/null || true)"
    if grep -q "DROPPED" <<<"$flows"; then
      echo "PASS: the filters select a DROPPED flow to port 8080 on $agent"
      exit 0
    fi
  done
  sleep 3
done
echo "FAIL: no DROPPED flow from drifter to probe port 8080 was found"
exit 1
