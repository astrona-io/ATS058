#!/usr/bin/env bash
# service_map must name a map that the agent reports and that holds IPv4 services.
set -uo pipefail
agent="$(kubectl -n starfleet get configmap datapath-evidence -o jsonpath='{.data.agent_pod}' 2>/dev/null || true)"
name="$(kubectl -n starfleet get configmap datapath-evidence -o jsonpath='{.data.service_map}' 2>/dev/null || true)"
case "$name" in
  *lb4_services*) ;;
  *) echo "FAIL: '${name}' is not the name of the IPv4 service map"; exit 1 ;;
esac
maps="$(kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg map list 2>&1)" || { echo "FAIL: cilium-dbg map list failed in ${agent}"; exit 1; }
if ! grep -q "$name" <<<"$maps"; then
  echo "FAIL: the agent does not list a map named '${name}'"
  exit 1
fi
echo "PASS: ${name} is a real BPF map of the agent"
