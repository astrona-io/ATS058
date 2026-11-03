#!/usr/bin/env bash
# The evidence ConfigMap exists and every required key is present and not empty.
set -uo pipefail
fail=0
for key in probe_cluster_ip probe_backend agent_pod service_map; do
  value="$(kubectl -n starfleet get configmap datapath-evidence -o "jsonpath={.data.${key}}" 2>/dev/null || true)"
  if [ -z "$value" ]; then
    echo "FAIL: ConfigMap starfleet/datapath-evidence has no value for the key ${key}"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "PASS: datapath-evidence has all four keys"
exit "$fail"
