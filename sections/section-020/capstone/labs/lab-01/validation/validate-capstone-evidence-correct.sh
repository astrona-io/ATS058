#!/usr/bin/env bash
# capstone-evidence keys: frontends_in_map (10), hubble_verdict (FORWARDED),
# destination_pod (name of the probe pod), relay_service (hubble-relay).
set -uo pipefail
get() { kubectl -n starfleet get configmap capstone-evidence -o "jsonpath={.data.$1}" 2>/dev/null || true; }
probe_pod="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
fail=0
[ "$(get frontends_in_map)" = "10" ] || { echo "FAIL: frontends_in_map must be 10"; fail=1; }
[ "$(get hubble_verdict)" = "FORWARDED" ] || { echo "FAIL: hubble_verdict must be FORWARDED"; fail=1; }
[ -n "$probe_pod" ] && [ "$(get destination_pod)" = "$probe_pod" ] || { echo "FAIL: destination_pod must be '${probe_pod}'"; fail=1; }
[ "$(get relay_service)" = "hubble-relay" ] || { echo "FAIL: relay_service must be hubble-relay"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: capstone-evidence is correct"
exit "$fail"
