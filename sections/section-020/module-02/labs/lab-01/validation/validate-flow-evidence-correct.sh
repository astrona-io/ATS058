#!/usr/bin/env bash
# flow-evidence keys: forwarded_client (shuttle), dropped_client (drifter),
# drop_reason (Policy denied, any letter case).
set -uo pipefail
get() { kubectl -n starfleet get configmap flow-evidence -o "jsonpath={.data.$1}" 2>/dev/null || true; }
fail=0
[ "$(get forwarded_client)" = "shuttle" ] || { echo "FAIL: forwarded_client must be shuttle"; fail=1; }
[ "$(get dropped_client)" = "drifter" ] || { echo "FAIL: dropped_client must be drifter"; fail=1; }
reason="$(get drop_reason | tr '[:upper:]' '[:lower:]')"
[ "$reason" = "policy denied" ] || { echo "FAIL: drop_reason is '${reason}', expected Policy denied"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: flow-evidence is correct"
exit "$fail"
