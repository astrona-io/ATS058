---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# eBPF Hooks, Programs And Maps In Cilium

Extended Berkeley Packet Filter, or eBPF, provides a way to run constrained programs at supported Linux kernel execution points. Cilium uses it for selected networking, service, policy and observation operations. The mechanism is easier to understand when programs, hooks, maps and control ownership are treated separately.

## Hooks Define The Execution Context

A hook determines when a program runs and what context it can access. Networking hooks can operate on packets or socket-related activity under supported kernel capabilities. Other eBPF uses can observe different system events. One program does not automatically see every event or perform every kernel function.

The selected hook affects which traffic and identity context are available. A socket-level operation and an interface-level packet operation can observe different portions of a connection. Diagnosing a datapath therefore requires knowing where the relevant behavior is implemented rather than assume one universal packet inspection point.

## Programs And Maps Cooperate

Program logic defines the operations performed at a hook. Maps provide supported data structures that can hold changing state such as backend, policy or connection information. Control components can update relevant map state, while programs consult it during execution. The exact structures and ownership depend on the implementation.

This arrangement allows some networking decisions to use local programmed state rather than query the Kubernetes API for every packet. It does not eliminate the need for agents to observe and reconcile current resources. Stale or incorrect map state can produce behavior inconsistent with current desired configuration even when the program itself loads successfully.

## Verification Has A Defined Purpose

Before a program is accepted, the kernel verifier assesses it under the supported safety rules. It analyzes properties needed for controlled execution, such as permitted memory access and valid operations within the program's context. Those checks are an important boundary, but not a proof that the program expresses the administrator's intended network policy.

A program can be verifier-acceptable while using an overly broad allowed peer set or incorrect Service state. Likewise, a correctly intended feature can fail to load if the kernel lacks a required capability. Separate execution safety, platform compatibility and policy correctness.

## Loading Requires Authority And Compatibility

Program loading and attachment need appropriate privileges and supported kernel facilities. Cilium's deployment must satisfy those requirements through its supported host and security arrangement. An application container cannot be assumed to have the same authority merely because the node uses eBPF.

Kernel versions and configuration influence feature availability. Cilium can use supported capabilities according to its compatibility model, but no single eBPF label guarantees every advanced feature on every host. Review the intended release and enabled configuration before relying on a hook or operation.

## eBPF Does Not Replace Every Responsibility

Routing, connection handling and other kernel mechanisms still participate where appropriate. Application-aware processing can involve proxies, and business authorization remains within its own contract. Hubble uses supported observations from the networking implementation rather than automatically supplying complete application traces.

For a failure, distinguish loading or attachment, control-state reconciliation, map contents and actual observed traffic. That identifies whether the problem is platform support, current state or another path relationship. It also keeps performance and security claims tied to the operation and environment where they are justified.

## Common pitfalls

> [!WARNING]
> Verifier acceptance is not proof of correct policy intent. Hooks have specific scope, maps hold changing state, and eBPF-based networking still depends on compatible hosts and other processing components.
