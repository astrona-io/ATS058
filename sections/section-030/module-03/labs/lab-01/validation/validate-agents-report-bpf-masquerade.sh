#!/usr/bin/env bash
# Every agent reports the BPF masquerading mode.
set -uo pipefail
for agent in $(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}'); do
  ok=0
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    # Output format of the status line is not verified; the check only looks for the word BPF after Masquerading.
    if kubectl -n kube-system exec "$agent" -c cilium-agent -- cilium-dbg status 2>/dev/null | grep -Eq 'Masquerading: +BPF'; then ok=1; break; fi
    sleep 3
  done
  if [ "$ok" -ne 1 ]; then
    echo "FAIL: ${agent} does not report Masquerading: BPF; restart the agents after the upgrade"
    exit 1
  fi
done
echo "PASS: every agent reports eBPF masquerading"
