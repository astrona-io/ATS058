#!/usr/bin/env bash
# capstone-evidence keys: kube_proxy_replacement (True), nodeport (30080), probe_backends (3).
set -uo pipefail
get() { kubectl -n starfleet get configmap capstone-evidence -o "jsonpath={.data.$1}" 2>/dev/null || true; }
agent="$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
status="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg status 2>/dev/null | grep -E 'KubeProxyReplacement' | head -n 1 | awk '{print $2}')"
backends="$(kubectl -n starfleet get pods -l app=probe --field-selector=status.phase=Running -o name | wc -l | tr -d ' ')"
fail=0
[ -n "$status" ] && [ "$(get kube_proxy_replacement)" = "$status" ] || { echo "FAIL: kube_proxy_replacement is '$(get kube_proxy_replacement)', the agent reports '${status}'"; fail=1; }
[ "$(get nodeport)" = "$(kubectl -n starfleet get service probe-nodeport -o jsonpath='{.spec.ports[0].nodePort}')" ] || { echo "FAIL: nodeport must be the node port of probe-nodeport"; fail=1; }
[ "$(get probe_backends)" = "$backends" ] || { echo "FAIL: probe_backends is '$(get probe_backends)', ${backends} probe pods run"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: capstone-evidence is correct"
exit "$fail"
