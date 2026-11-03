---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# eBPF Key Benefits

This section explains what the eBPF datapath gains and where each gain has limits. The first module compares map lookups and incremental updates with rule chains, then covers socket load balancing, eBPF host routing and XDP. The second module covers Hubble observability, the safety guarantees of the verifier, live updates of programs and maps, and how the datapath behaves while the agent restarts. Each of these modules has two more parts on backend selection and bandwidth, Hubble metrics and encryption. The third module covers the Hubble command line, Layer 7 service mesh features, Tetragon and the wider eBPF ecosystem.

Each of the three modules has a playground and a graded lab. The section ends with a capstone lab and a knowledge check.

## Learning Outcomes

- Explain why a hash map lookup takes constant time and why a map update changes one entry.
- Describe how socket load balancing changes a Service address at `connect()`.
- Name the conditions under which eBPF host routing and XDP are used and when Cilium falls back.
- Read forwarded and dropped flows with Hubble and explain the drop reason.
- Explain why the datapath keeps working while the agent restarts.
- Compare random and Maglev backend selection and the SNAT and DSR modes.
- Enable Hubble metrics and the Hubble UI, and filter flows with `hubble observe`.
- Name the security benefits of identity-based policy and transparent encryption.
- Name the role of Envoy, Tetragon and other eBPF projects next to the Cilium datapath.
- State that the benefit of each feature depends on the kernel and the configuration.
