#!/usr/bin/env bash
# flow-filter-evidence keys: dropped_client (drifter), destination_port (8080),
# protocol (TCP, any letter case), source_identity (identity of the drifter CiliumEndpoint).
set -uo pipefail
get() { kubectl -n starfleet get configmap flow-filter-evidence -o "jsonpath={.data.$1}" 2>/dev/null || true; }
fail=0
[ "$(get dropped_client)" = "drifter" ] || { echo "FAIL: dropped_client must be drifter"; fail=1; }
[ "$(get destination_port)" = "8080" ] || { echo "FAIL: destination_port must be 8080"; fail=1; }
[ "$(get protocol | tr '[:lower:]' '[:upper:]')" = "TCP" ] || { echo "FAIL: protocol must be TCP"; fail=1; }
id="$(kubectl -n outpost get ciliumendpoints -o jsonpath='{.items[0].status.identity.id}' 2>/dev/null || true)"
if [ -z "$id" ] || [ "$(get source_identity)" != "$id" ]; then
  echo "FAIL: source_identity must equal the identity of the drifter CiliumEndpoint"; fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: flow-filter-evidence is correct"
exit "$fail"
