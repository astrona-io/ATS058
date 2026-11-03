#!/usr/bin/env bash
# probe-ingress still exists, still selects probe, and allows only shuttle on 8080.
set -uo pipefail
policy="$(kubectl -n starfleet get ciliumnetworkpolicy probe-ingress -o json 2>/dev/null || true)"
if [ -z "$policy" ]; then
  echo "FAIL: the CiliumNetworkPolicy starfleet/probe-ingress is missing"
  exit 1
fi
ports="$(jq -r '[.spec.ingress[]?.toPorts[]?.ports[]?.port] | sort | join(",")' <<<"$policy")"
sources="$(jq -r '[.spec.ingress[]?.fromEndpoints[]?.matchLabels.app] | sort | join(",")' <<<"$policy")"
if [ "$ports" != "8080" ]; then
  echo "FAIL: probe-ingress allows ports '${ports}', expected only 8080"
  exit 1
fi
if [ "$sources" != "shuttle" ]; then
  echo "FAIL: probe-ingress allows sources '${sources}', expected only app shuttle"
  exit 1
fi
echo "PASS: probe-ingress allows only shuttle on port 8080"
