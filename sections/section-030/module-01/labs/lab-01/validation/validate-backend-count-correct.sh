#!/usr/bin/env bash
# Count the KUBE-SEP jumps inside the Service chain and compare with the evidence and the pods.
set -uo pipefail
proxy="$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
rules="$(kubectl -n kube-system exec "$proxy" -- iptables-save -t nat 2>&1)" || { echo "FAIL: iptables-save failed in ${proxy}"; exit 1; }
chain="$(kubectl -n starfleet get configmap iptables-evidence -o jsonpath='{.data.service_chain}' 2>/dev/null || true)"
count="$(grep -c -- "^-A ${chain} .*-j KUBE-SEP-" <<<"$rules" || true)"
pods="$(kubectl -n starfleet get pods -l app=probe --field-selector=status.phase=Running -o name | wc -l | tr -d ' ')"
recorded="$(kubectl -n starfleet get configmap iptables-evidence -o jsonpath='{.data.backend_chain_count}' 2>/dev/null || true)"
if [ -z "$chain" ] || [ "${count:-0}" -lt 1 ]; then echo "FAIL: chain '${chain}' has no KUBE-SEP jumps in the nat table"; exit 1; fi
if [ "$recorded" != "$count" ] || [ "$count" != "$pods" ]; then
  echo "FAIL: backend_chain_count is '${recorded}', the chain has ${count} KUBE-SEP jumps and ${pods} probe pods run"
  exit 1
fi
echo "PASS: ${count} KUBE-SEP chains match ${pods} probe pods"
