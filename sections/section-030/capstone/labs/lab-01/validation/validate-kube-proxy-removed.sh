#!/usr/bin/env bash
# The kube-proxy DaemonSet is gone.
set -uo pipefail
if kubectl -n kube-system get daemonset kube-proxy >/dev/null 2>&1; then
  echo "FAIL: the kube-proxy DaemonSet still exists in kube-system"
  exit 1
fi
echo "PASS: kube-proxy is removed"
