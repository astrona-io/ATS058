#!/usr/bin/env bash
# A real request from drifter must not succeed. The pod must also exist, so a
# missing client cannot pass this check.
set -uo pipefail
if ! kubectl -n outpost get deploy drifter >/dev/null 2>&1; then
  echo "FAIL: the drifter Deployment in outpost is missing"
  exit 1
fi
# A policy must select probe, otherwise a blocked request proves nothing.
if ! kubectl -n starfleet get ciliumnetworkpolicies -o jsonpath='{range .items[*]}{.spec.endpointSelector.matchLabels.app}{"\n"}{end}' 2>/dev/null | grep -qx probe; then
  echo "FAIL: no CiliumNetworkPolicy selects the probe pods"
  exit 1
fi
code="$(kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null -w '%{http_code}' http://probe.starfleet.svc/status/200 2>/dev/null || true)"
if [ "$code" = "200" ]; then
  echo "FAIL: drifter still gets HTTP 200 from probe"
  exit 1
fi
echo "PASS: drifter cannot reach probe (code: '${code}')"
