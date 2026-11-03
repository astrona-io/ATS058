#!/usr/bin/env bash
# Reference solution.
set -euo pipefail
cat <<'YAML' | kubectl apply -f -
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-from-shuttle
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: shuttle
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP
YAML
pod="$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[0].metadata.name}')"
identity="$(kubectl -n starfleet get ciliumendpoint "$pod" -o jsonpath='{.status.identity.id}')"
kubectl -n starfleet create configmap identity-evidence --from-literal=shuttle_identity="$identity" --dry-run=client -o yaml | kubectl apply -f -
