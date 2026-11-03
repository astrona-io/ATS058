#!/usr/bin/env bash
# The Cilium configuration turns kube-proxy replacement on and every agent reports it.
set -uo pipefail
value="$(kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.kube-proxy-replacement}' 2>/dev/null || true)"
if [ "$value" != "true" ]; then
  echo "FAIL: kube-proxy-replacement in cilium-config is '${value}', expected true"
  exit 1
fi
for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
  ok=0
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg status 2>/dev/null | grep -Eq 'KubeProxyReplacement: +True'; then ok=1; break; fi
    sleep 3
  done
  if [ "$ok" -ne 1 ]; then
    echo "FAIL: ${agent} does not report KubeProxyReplacement: True; restart the agents after the upgrade"
    exit 1
  fi
done
echo "PASS: the agents run with kube-proxy replacement"
