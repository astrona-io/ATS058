#!/usr/bin/env bash
# At least one CiliumNetworkPolicy in starfleet selects app=probe.
set -uo pipefail
found="$(kubectl -n starfleet get ciliumnetworkpolicies -o jsonpath='{range .items[*]}{.spec.endpointSelector.matchLabels.app}{"\n"}{end}' 2>/dev/null | grep -cx probe || true)"
if [ "${found:-0}" -lt 1 ]; then
  echo "FAIL: no CiliumNetworkPolicy in starfleet has endpointSelector matchLabels app: probe"
  exit 1
fi
echo "PASS: a CiliumNetworkPolicy selects the probe pods"
