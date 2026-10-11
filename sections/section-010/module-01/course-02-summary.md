---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# Summary

eBPF runs verified programs at supported hooks and uses maps for state shared with appropriate control components. Cilium applies these mechanisms to selected networking, policy and observation responsibilities.

The verifier constrains program execution rather than proving policy intent or application correctness. Kernel capabilities, loading authority and programmed state remain prerequisites, while proxies and ordinary kernel networking can still participate in the complete path.
