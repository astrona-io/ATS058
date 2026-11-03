#!/usr/bin/env bash
# agent_pod must be the Cilium agent pod on the node of the probe pod.
set -uo pipefail
node="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].spec.nodeName}' 2>/dev/null || true)"
live="$(kubectl -n kube-system get pods -l k8s-app=cilium --field-selector "spec.nodeName=${node}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap node-evidence -o jsonpath='{.data.agent_pod}' 2>/dev/null || true)"
if [ -z "$live" ] || [ "$recorded" != "$live" ]; then
  echo "FAIL: agent_pod is '${recorded}', the agent on node '${node}' is '${live}'"
  exit 1
fi
echo "PASS: agent_pod is the agent of the probe node"
