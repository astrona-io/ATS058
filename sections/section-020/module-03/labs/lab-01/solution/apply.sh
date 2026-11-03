#!/usr/bin/env bash
# Reference solution.
set -euo pipefail
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/status/200 || true
id="$(kubectl -n outpost get ciliumendpoints -o jsonpath='{.items[0].status.identity.id}')"
kubectl -n starfleet create configmap flow-filter-evidence \
  --from-literal=dropped_client=drifter --from-literal=destination_port=8080 \
  --from-literal=protocol=TCP --from-literal=source_identity="$id" --dry-run=client -o yaml | kubectl apply -f -
