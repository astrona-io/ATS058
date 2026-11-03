#!/usr/bin/env bash
set -uo pipefail
for attempt in 1 2 3 4 5 6 8 10; do
  code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' http://probe.starfleet.svc/status/200 2>/dev/null || true)"
  if [ "$code" = "200" ]; then echo "PASS: shuttle reaches probe (HTTP 200)"; exit 0; fi
  sleep 3
done
echo "FAIL: shuttle reaches probe (last code: '${code}')"
exit 1
