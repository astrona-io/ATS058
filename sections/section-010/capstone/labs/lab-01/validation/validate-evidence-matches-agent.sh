#!/usr/bin/env bash
# capstone-evidence keys: shuttle_identity, drifter_identity, probe_endpoint_id,
# probe_backend. Each is compared with live cluster state.
set -uo pipefail
get() { kubectl -n starfleet get configmap capstone-evidence -o "jsonpath={.data.$1}" 2>/dev/null || true; }
cep() { kubectl -n "$1" get ciliumendpoint "$2" -o "jsonpath=$3" 2>/dev/null || true; }
fail=0
shuttle_pod="$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[0].metadata.name}')"
drifter_pod="$(kubectl -n outpost get pods -l app=drifter -o jsonpath='{.items[0].metadata.name}')"
probe_pod="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}')"
probe_ip="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.podIP}')"
check() {
  local key="$1" expected="$2" recorded
  recorded="$(get "$key")"
  if [ -z "$expected" ] || [ "$recorded" != "$expected" ]; then
    echo "FAIL: ${key} is '${recorded}', expected '${expected}'"
    fail=1
  fi
}
check shuttle_identity "$(cep starfleet "$shuttle_pod" '{.status.identity.id}')"
check drifter_identity "$(cep outpost "$drifter_pod" '{.status.identity.id}')"
check probe_endpoint_id "$(cep starfleet "$probe_pod" '{.status.id}')"
check probe_backend "${probe_ip}:8080"
[ "$fail" -eq 0 ] && echo "PASS: capstone-evidence matches the live state"
exit "$fail"
