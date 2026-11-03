#!/usr/bin/env bash
# Hubble is enabled in the Cilium configuration and Hubble Relay is running.
set -uo pipefail
enabled="$(kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.enable-hubble}' 2>/dev/null || true)"
if [ "$enabled" != "true" ]; then
  echo "FAIL: enable-hubble in cilium-config is '${enabled}', expected true"
  exit 1
fi
ready="$(kubectl -n kube-system get deployment hubble-relay -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" -lt 1 ]; then
  echo "FAIL: the hubble-relay Deployment has no ready replica"
  exit 1
fi
if ! kubectl -n kube-system get service hubble-relay >/dev/null 2>&1; then
  echo "FAIL: the hubble-relay Service is missing"
  exit 1
fi
echo "PASS: Hubble and Hubble Relay are running"
