#!/usr/bin/env bash
# The Cilium configuration turns eBPF masquerading on.
set -uo pipefail
value="$(kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.enable-bpf-masquerade}' 2>/dev/null || true)"
if [ "$value" != "true" ]; then
  echo "FAIL: enable-bpf-masquerade in cilium-config is '${value}', expected true"
  exit 1
fi
echo "PASS: eBPF masquerading is configured"
