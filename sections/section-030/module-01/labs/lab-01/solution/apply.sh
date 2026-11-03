#!/usr/bin/env bash
# Reference solution.
set -euo pipefail
proxy="$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}')"
rules="$(kubectl -n kube-system exec "$proxy" -- iptables-save -t nat)"
chain="$(grep -- 'starfleet/probe:http cluster IP' <<<"$rules" | sed -n 's/.*-j \(KUBE-SVC-[A-Z0-9]*\).*/\1/p' | head -n 1)"
count="$(grep -c -- "^-A ${chain} .*-j KUBE-SEP-" <<<"$rules")"
kubectl -n starfleet create configmap iptables-evidence \
  --from-literal=probe_cluster_ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}')" \
  --from-literal=service_chain="$chain" --from-literal=backend_chain_count="$count" \
  --dry-run=client -o yaml | kubectl apply -f -
