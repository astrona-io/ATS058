---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# eBPF-based Platforms versus IPtables-based Platforms

This section compares the two Service models. The first module explains how kube-proxy writes iptables rules in the nat table, how the KUBE-SERVICES, KUBE-SVC and KUBE-SEP chains choose a backend, and where this model stops scaling. The second module explains how Cilium replaces kube-proxy, how to migrate a cluster and how to clean up the old rules.

Each module has a playground and a graded lab. The section ends with a capstone lab and a knowledge check.

## Learning Outcomes

- Trace a request to a cluster IP through the chains that kube-proxy creates.
- Name the scaling limits of ordered chains, full table synchronization, conntrack and IP-based policy.
- Enable kube-proxy replacement with the Helm values that it needs.
- Remove the kube-proxy DaemonSet and its leftover rules.
- Verify the replacement with the agent status and the service map.
