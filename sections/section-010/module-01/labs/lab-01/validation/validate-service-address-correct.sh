#!/usr/bin/env bash
# probe_cluster_ip must equal the live cluster IP of the probe Service.
set -uo pipefail
live="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap datapath-evidence -o jsonpath='{.data.probe_cluster_ip}' 2>/dev/null || true)"
if [ -z "$live" ] || [ "$recorded" != "$live" ]; then
  echo "FAIL: probe_cluster_ip is '${recorded}', the Service has '${live}'"
  exit 1
fi
echo "PASS: probe_cluster_ip matches the Service"
