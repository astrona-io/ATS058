#!/usr/bin/env bash
# The ConfigMap masquerade-evidence matches the cluster.
set -uo pipefail
fail=0
get() { kubectl -n starfleet get configmap masquerade-evidence -o "jsonpath={.data.$1}" 2>/dev/null || true; }
mode="$(get masquerade_mode)"
agents="$(get agent_count)"
if [ "$mode" != "BPF" ]; then echo "FAIL: masquerade_mode is '${mode}', expected BPF"; fail=1; fi
actual="$(kubectl -n kube-system get pods -l k8s-app=cilium --no-headers 2>/dev/null | wc -l | tr -d ' ')"
if [ "$agents" != "$actual" ]; then echo "FAIL: agent_count is '${agents}', the cluster has ${actual} agents"; fail=1; fi
[ "$fail" -eq 0 ] && echo "PASS: masquerade-evidence is correct"
exit "$fail"
