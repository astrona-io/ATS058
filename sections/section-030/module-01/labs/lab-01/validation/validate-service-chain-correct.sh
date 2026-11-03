#!/usr/bin/env bash
# Recompute the Service chain from the live iptables rules of a kube-proxy pod.
set -uo pipefail
proxy="$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
rules="$(kubectl -n kube-system exec "$proxy" -- iptables-save -t nat 2>&1)" || { echo "FAIL: iptables-save failed in ${proxy}"; exit 1; }
chain="$(grep -- 'starfleet/probe:http cluster IP' <<<"$rules" | sed -n 's/.*-j \(KUBE-SVC-[A-Z0-9]*\).*/\1/p' | head -n 1)"
recorded="$(kubectl -n starfleet get configmap iptables-evidence -o jsonpath='{.data.service_chain}' 2>/dev/null || true)"
if [ -z "$chain" ]; then echo "FAIL: no Service chain for starfleet/probe:http found in the nat table"; exit 1; fi
if [ "$recorded" != "$chain" ]; then echo "FAIL: service_chain is '${recorded}', the nat table has '${chain}'"; exit 1; fi
echo "PASS: service_chain is ${chain}"
