#!/usr/bin/env bash
# Reference solution.
set -euo pipefail
pod="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].metadata.name}')"
ip="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.status.podIP}')"
node="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.nodeName}')"
agent="$(kubectl -n kube-system get pods -l k8s-app=cilium --field-selector "spec.nodeName=${node}" -o jsonpath='{.items[0].metadata.name}')"
endpoint_id="$(kubectl -n starfleet get ciliumendpoint "$pod" -o jsonpath='{.status.id}')"
identity="$(kubectl -n starfleet get ciliumendpoint "$pod" -o jsonpath='{.status.identity.id}')"
kubectl -n starfleet create configmap node-evidence \
  --from-literal=probe_pod_ip="$ip" \
  --from-literal=probe_endpoint_id="$endpoint_id" \
  --from-literal=probe_identity="$(kubectl -n starfleet get ciliumendpoint "$pod" -o jsonpath='{.status.identity.id}')"
  --from-literal=agent_pod="$agent" \
  --dry-run=client -o yaml | kubectl apply -f -
