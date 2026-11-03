#!/usr/bin/env bash
# The agent named in agent_pod must be a real Cilium agent pod and its
# service map must list the cluster IP and the backend address.
set -uo pipefail
agent="$(kubectl -n starfleet get configmap datapath-evidence -o jsonpath='{.data.agent_pod}' 2>/dev/null || true)"
service_ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)"
pod_ip="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.podIP}' 2>/dev/null || true)"
if ! kubectl -n kube-system get pods -l k8s-app=cilium -o name | grep -qx "pod/${agent}"; then
  echo "FAIL: '${agent}' is not a Cilium agent pod in kube-system"
  exit 1
fi
map="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg bpf lb list 2>&1)" || { echo "FAIL: cilium-dbg bpf lb list failed in ${agent}"; exit 1; }
if ! grep -q "${service_ip}:80" <<<"$map"; then
  echo "FAIL: the service map of ${agent} has no entry for ${service_ip}:80"
  exit 1
fi
if ! grep -q "${pod_ip}:8080" <<<"$map"; then
  echo "FAIL: the service map of ${agent} has no backend ${pod_ip}:8080"
  exit 1
fi
echo "PASS: the service map lists the Service and its backend"
