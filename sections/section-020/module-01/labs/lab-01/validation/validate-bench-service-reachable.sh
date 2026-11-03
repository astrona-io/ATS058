#!/usr/bin/env bash
# A real request from shuttle must return HTTP 200.
set -uo pipefail
for attempt in 1 2 3 4 5 6 7 8; do
  code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null -w '%{http_code}' http://bench-20.starfleet.svc/status/200 2>/dev/null || true)"
  if [ "$code" = "200" ]; then
    echo "PASS: shuttle reaches probe through bench-20 (HTTP 200)"
    exit 0
  fi
  sleep 3
done
echo "FAIL: shuttle reaches probe through bench-20 (last code: '${code}')"
exit 1
