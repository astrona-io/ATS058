#!/usr/bin/env bash
# shuttle_identity must equal the identity Cilium assigned to the shuttle pod.
set -uo pipefail
pod="$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
live="$(kubectl -n starfleet get ciliumendpoint "$pod" -o jsonpath='{.status.identity.id}' 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap identity-evidence -o jsonpath='{.data.shuttle_identity}' 2>/dev/null || true)"
if [ -z "$live" ] || [ "$recorded" != "$live" ]; then
  echo "FAIL: shuttle_identity is '${recorded}', Cilium reports '${live}'"
  exit 1
fi
echo "PASS: shuttle_identity matches the CiliumEndpoint"
