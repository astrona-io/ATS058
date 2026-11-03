#!/usr/bin/env bash
# probe_endpoint_id must equal the endpoint ID in the CiliumEndpoint of the probe pod.
set -uo pipefail
pod="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
live="$(kubectl -n starfleet get ciliumendpoint "$pod" -o jsonpath='{.status.id}' 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap node-evidence -o jsonpath='{.data.probe_endpoint_id}' 2>/dev/null || true)"
if [ -z "$live" ] || [ "$recorded" != "$live" ]; then
  echo "FAIL: probe_endpoint_id is '${recorded}', Cilium reports '${live}'"
  exit 1
fi
echo "PASS: probe_endpoint_id matches the CiliumEndpoint"
