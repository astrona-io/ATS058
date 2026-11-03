#!/usr/bin/env bash
# probe_backend must be <pod IP>:8080 of the one probe pod.
set -uo pipefail
pod_ip="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.podIP}' 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap datapath-evidence -o jsonpath='{.data.probe_backend}' 2>/dev/null || true)"
if [ -z "$pod_ip" ] || [ "$recorded" != "${pod_ip}:8080" ]; then
  echo "FAIL: probe_backend is '${recorded}', expected '${pod_ip}:8080'"
  exit 1
fi
echo "PASS: probe_backend matches the probe pod"
