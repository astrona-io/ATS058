#!/usr/bin/env bash
set -uo pipefail
fail=0
for key in probe_cluster_ip service_chain backend_chain_count; do
  value="$(kubectl -n starfleet get configmap iptables-evidence -o "jsonpath={.data.${key}}" 2>/dev/null || true)"
  if [ -z "$value" ]; then echo "FAIL: ConfigMap starfleet/iptables-evidence has no value for ${key}"; fail=1; fi
done
service_ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap iptables-evidence -o jsonpath='{.data.probe_cluster_ip}' 2>/dev/null || true)"
if [ -n "$recorded" ] && [ "$recorded" != "$service_ip" ]; then echo "FAIL: probe_cluster_ip is '${recorded}', the Service has '${service_ip}'"; fail=1; fi
[ "$fail" -eq 0 ] && echo "PASS: iptables-evidence has the required keys"
exit "$fail"
