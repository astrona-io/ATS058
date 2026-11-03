#!/usr/bin/env bash
# Reference solution: read the facts from the cluster and record them.
set -euo pipefail
agent="$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')"
service_ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}')"
pod_ip="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.podIP}')"
map_name="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg map list | grep -o 'cilium_lb4_services[A-Za-z0-9_]*' | head -n 1)"
kubectl -n starfleet create configmap datapath-evidence \
  --from-literal=probe_cluster_ip="$service_ip" \
  --from-literal=probe_backend="${pod_ip}:8080" \
  --from-literal=agent_pod="$agent" \
  --from-literal=service_map="$map_name" \
  --dry-run=client -o yaml | kubectl apply -f -
