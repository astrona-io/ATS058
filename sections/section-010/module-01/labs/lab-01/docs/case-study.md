---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# Starting Environment

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Prove the probe Service address is present in a real BPF service map.
