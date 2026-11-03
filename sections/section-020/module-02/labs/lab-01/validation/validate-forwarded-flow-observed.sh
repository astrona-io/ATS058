#!/usr/bin/env bash
# Send one request, then look for the flow in the Hubble ring buffer of the agents.
set -uo pipefail
namespace=starfleet; [ "shuttle" = drifter ] && namespace=outpost
kubectl -n "$namespace" exec deploy/shuttle -- curl -s -m 4 -o /dev/null http://probe.starfleet.svc/status/200 >/dev/null 2>&1 || true
for attempt in 1 2 3 4 5 6 7 8; do
  for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
    flows="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- hubble observe --from-label app=shuttle --to-label app=probe --verdict FORWARDED --last 50 2>/dev/null || true)"
    if grep -q "FORWARDED" <<<"$flows"; then
      echo "PASS: found a FORWARDED flow from shuttle to probe on $agent"
      exit 0
    fi
  done
  sleep 3
done
echo "FAIL: no FORWARDED flow from shuttle to probe was found in Hubble"
exit 1
