#!/usr/bin/env bash
# probe_identity must equal the identity Cilium assigned to the probe pod.
set -uo pipefail
pod="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
live="$(kubectl -n starfleet get ciliumendpoint "$pod" -o jsonpath='{.status.identity.id}' 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap node-evidence -o jsonpath='{.data.probe_identity}' 2>/dev/null || true)"
if [ -z "$live" ] || [ "$recorded" != "$live" ]; then
  echo "FAIL: probe_identity is '${recorded}', Cilium reports '${live}'"
  exit 1
fi
echo "PASS: probe_identity matches the CiliumEndpoint"
