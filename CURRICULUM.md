# Curriculum Coverage

Exam: Cilium Certified Associate (CCA). Domain: eBPF (10%).

The [official objectives](https://training.linuxfoundation.org/certification/cilium-certified-associate-cca/) were checked on 2026-10-11. The teaching structure is independently authored and adds no official requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Understand the Role of eBPF in Cilium | 2 |
| 020 | eBPF Key Benefits | 2 |
| 030 | eBPF-based Platforms versus IPtables-based Platforms | 2 |

| Section / module | Module | Parts |
| --- | --- | --- |
| 010 / 01 | eBPF Programs, Hooks And Maps | Programs, verifier and loading; hooks and maps |
| 010 / 02 | The Cilium Agent, Identities And The Datapath | Agent, endpoints and identity; policy and service datapath |
| 020 / 01 | Lookups, Updates And Shorter Packet Paths | Lookups and updates; shorter packet paths |
| 020 / 02 | Observability, Safety And Live Updates | Observability with Hubble; safety, live updates and agent restart |
| 030 / 01 | How kube-proxy Uses iptables, And Where It Stops Scaling | Netfilter and kube-proxy chains; scaling limits of iptables |
| 030 / 02 | Replacing kube-proxy With Cilium | kube-proxy replacement; migration and cleanup |

AUTHORING.yaml records the goals and the labs. All technical readings stay draft. Every section has a capstone lab and a knowledge check, and the course has a final domain quiz.

## Hands-On Coverage

| Module | Lab after the part it practises |
| --- | --- |
| 010 / 01 | Read the service datapath from the agent |
| 010 / 02 | Allow one client with a CiliumNetworkPolicy |
| 010 | Capstone: fix a policy that blocks the allowed client |
| 020 / 01 | Add twenty Services and read them in the service map |
| 020 / 02 | Enable Hubble and observe a forwarded and a dropped flow |
| 020 | Capstone: enable Hubble and add Services |
| 030 / 01 | Find the kube-proxy rules of a Service |
| 030 / 02 | Replace kube-proxy with Cilium |
| 030 | Capstone: replace kube-proxy and keep a NodePort working |

All runtime behavior is UNTESTED. Only static checks were run.
