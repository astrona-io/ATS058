#!/usr/bin/env bash
# Services bench-01 to bench-20 must exist in starfleet, select the probe pods and use port 80.
set -uo pipefail
fail=0
for number in $(seq 1 20); do
  name="bench-$(printf '%02d' "$number")"
  selector="$(kubectl -n starfleet get service "$name" -o jsonpath='{.spec.selector.app}' 2>/dev/null || true)"
  port="$(kubectl -n starfleet get service "$name" -o jsonpath='{.spec.ports[0].port}' 2>/dev/null || true)"
  if [ "$selector" != "probe" ] || [ "$port" != "80" ]; then
    echo "FAIL: Service $name is missing or does not select app=probe on port 80"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "PASS: 20 bench Services exist"
exit "$fail"
