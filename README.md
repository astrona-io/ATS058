# eBPF (ATS058)

Cilium Certified Associate (CCA): eBPF, worth 10% of the official curriculum. This course belongs to ATP011.

The course has three sections, one for each official objective. Every section has two modules, a capstone lab and a knowledge check. Every module has a landing page, two reading parts, a summary, an ungraded playground and a graded lab. A final domain quiz closes the course. Technical pages stay marked as draft.

All labs and playgrounds are UNTESTED. They were written from the documentation and checked only with static checks (`astrona validate`, `bash -n` and YAML parsing). Nothing has been run on a live cluster.

## Course Outline

| Section | Official objective | Module 01 | Module 02 |
| --- | --- | --- | --- |
| 010 | Understand the Role of eBPF in Cilium | eBPF Programs, Hooks And Maps | The Cilium Agent, Identities And The Datapath |
| 020 | eBPF Key Benefits | Lookups, Updates And Shorter Packet Paths | Observability, Safety And Live Updates |
| 030 | eBPF-based Platforms versus IPtables-based Platforms | How kube-proxy Uses iptables, And Where It Stops Scaling | Replacing kube-proxy With Cilium |

## Hands-On Coverage

There are 6 playgrounds, 6 module labs and 3 capstone labs. Each lab follows the part it practises.

| Lab | Task |
| --- | --- |
| ats-058-lab-010-01 | Read the service datapath from the agent |
| ats-058-lab-010-02 | Allow one client with a CiliumNetworkPolicy |
| ats-058-lab-010-cap | Fix a policy that blocks the allowed client |
| ats-058-lab-020-01 | Add twenty Services and read them in the service map |
| ats-058-lab-020-02 | Enable Hubble and observe a forwarded and a dropped flow |
| ats-058-lab-020-cap | Enable Hubble and add Services |
| ats-058-lab-030-01 | Find the kube-proxy rules of a Service |
| ats-058-lab-030-02 | Replace kube-proxy with Cilium |
| ats-058-lab-030-cap | Replace kube-proxy and keep a NodePort working |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [knowledge check documentation](ASSESSMENTS.md) and [contribution instructions](CONTRIBUTING.md).
