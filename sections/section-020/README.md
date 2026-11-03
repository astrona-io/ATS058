---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# eBPF Key Benefits

This section explains what the eBPF datapath gains and where each gain has limits. The first module compares map lookups and incremental updates with rule chains, then covers socket load balancing, eBPF host routing and XDP. The second module covers Hubble observability, the safety guarantees of the verifier, live updates of programs and maps, and how the datapath behaves while the agent restarts.

Each module has a playground and a graded lab. The section ends with a capstone lab and a knowledge check.

## Learning Outcomes

- Explain why a hash map lookup takes constant time and why a map update changes one entry.
- Describe how socket load balancing changes a Service address at `connect()`.
- Name the conditions under which eBPF host routing and XDP are used and when Cilium falls back.
- Read forwarded and dropped flows with Hubble and explain the drop reason.
- Explain why the datapath keeps working while the agent restarts.
- State that the benefit of each feature depends on the kernel and the configuration.
