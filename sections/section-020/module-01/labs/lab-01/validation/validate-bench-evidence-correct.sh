#!/usr/bin/env bash
# bench-evidence must say 20 and 20, and 20 must be true in the live service map.
set -uo pipefail
created="$(kubectl -n starfleet get configmap bench-evidence -o jsonpath='{.data.services_created}' 2>/dev/null || true)"
frontends="$(kubectl -n starfleet get configmap bench-evidence -o jsonpath='{.data.frontends_in_map}' 2>/dev/null || true)"
live="$(kubectl -n starfleet get services -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep -c '^bench-[0-9][0-9]$' || true)"
if [ "$created" != "20" ] || [ "$live" != "20" ]; then
  echo "FAIL: services_created is '${created}' and the cluster has ${live} bench Services; both must be 20"
  exit 1
fi
if [ "$frontends" != "20" ]; then
  echo "FAIL: frontends_in_map is '${frontends}', expected 20"
  exit 1
fi
echo "PASS: bench-evidence records 20 Services and 20 frontends"
