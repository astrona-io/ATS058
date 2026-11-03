#!/usr/bin/env bash
# Send one request to bench-10, then look for a FORWARDED flow shuttle -> probe pod.
set -uo pipefail
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://bench-10.starfleet.svc/status/200 >/dev/null 2>&1 || true
probe_pod="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
for attempt in 1 2 3 4 5 6 7 8; do
  for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
    flows="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- hubble observe --from-label app=shuttle --to-label app=probe --verdict FORWARDED --last 50 2>/dev/null || true)"
    if grep -q "$probe_pod" <<<"$flows"; then
      echo "PASS: found a FORWARDED flow from shuttle to ${probe_pod} on ${agent}"
      exit 0
    fi
  done
  sleep 3
done
echo "FAIL: no FORWARDED flow from shuttle to ${probe_pod} found in Hubble"
exit 1
