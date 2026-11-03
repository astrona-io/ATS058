#!/usr/bin/env bash
# probe_pod_ip must equal the real pod IP of the probe pod.
set -uo pipefail
live="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.podIP}' 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap node-evidence -o jsonpath='{.data.probe_pod_ip}' 2>/dev/null || true)"
if [ -z "$live" ] || [ "$recorded" != "$live" ]; then
  echo "FAIL: probe_pod_ip is '${recorded}', the pod IP is '${live}'"
  exit 1
fi
echo "PASS: probe_pod_ip matches the pod"
