---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Summary

iptables and eBPF provide different mechanisms for expressing and executing networking behavior. Rule chains, connection state, hooks and maps shape their costs and observable context.

Cilium's supported kube-proxy replacement targets selected Service behavior rather than abolishing every host firewall or kernel network mechanism. Coexistence and performance need review in the actual deployment, with separate evidence for routing, policy and application service.
