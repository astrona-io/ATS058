#!/usr/bin/env bash
# Reference solution.
set -euo pipefail
kubectl -n starfleet patch ciliumnetworkpolicy probe-ingress --type=json \
  -p '[{"op":"replace","path":"/spec/ingress/0/toPorts/0/ports/0/port","value":"8080"}]'
shuttle_pod="$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[0].metadata.name}')"
drifter_pod="$(kubectl -n outpost get pods -l app=drifter -o jsonpath='{.items[0].metadata.name}')"
probe_pod="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}')"
probe_ip="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.podIP}')"
kubectl -n starfleet create configmap capstone-evidence \
  --from-literal=shuttle_identity="$(kubectl -n starfleet get ciliumendpoint "$shuttle_pod" -o jsonpath='{.status.identity.id}')" \
  --from-literal=drifter_identity="$(kubectl -n outpost get ciliumendpoint "$drifter_pod" -o jsonpath='{.status.identity.id}')" \
  --from-literal=probe_endpoint_id="$(kubectl -n starfleet get ciliumendpoint "$probe_pod" -o jsonpath='{.status.id}')" \
  --from-literal=probe_backend="${probe_ip}:8080" \
  --dry-run=client -o yaml | kubectl apply -f -
