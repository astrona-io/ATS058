---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Identify The kube-proxy Boundary

Prove the probe Service address is present in a real BPF service map.

The task and solution use a separate pinned kind cluster. Run `testing/smoke.sh` with its private kubeconfig to verify initial rejection and reference success. Static validation is not live evidence. Runtime verification remains pending.
