---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Security Benefits: Identity-Based Policy And Transparent Encryption

An eBPF datapath is not only faster. It also changes what network security can do, because the programs run in the kernel of every node, see every packet of every pod and can use data from the Cilium agent. This part covers three security benefits: policy that follows identity, enforcement without a proxy in each pod, and transparent encryption between nodes.

## Policy that follows identity

An IP address says little about a workload. A pod gets a new address when it restarts, and a rule that lists addresses must be rewritten after each change. Cilium gives each group of pods with the same security-relevant labels a numeric security identity. The agent writes the mapping from IP address to identity into the IP cache map, and a policy map holds, for each endpoint, the identities and ports that are allowed.

The rule `fromEndpoints` with a label selector therefore becomes a map entry for an identity, not for an address. When a pod restarts with a new IP address, the IP cache map changes and the policy map stays the same. Scale does not change the size of the rule: a hundred pods with the same labels share one identity and one entry.

## Default deny and the verdict

A pod that no policy selects accepts all traffic. When a policy selects an endpoint for ingress, the endpoint denies all ingress traffic that no rule allows. The eBPF program returns a drop verdict for that traffic, and Hubble shows it as `DROPPED` with the reason `Policy denied`. You saw this with the `drifter` client. The decision happens in the kernel at the pod interface, so the application never sees the denied connection attempt.

## No sidecar for enforcement

Some security models place a proxy container in every pod. The proxy then handles each connection of that pod. That model adds a container, memory and a start-up order to every workload. In Cilium the enforcement point is the eBPF program on the interface of the pod, so a pod needs no extra container for Layer 3 and Layer 4 policy. Layer 7 policy uses the Envoy proxy on the node, not one in each pod. Enforcement is therefore the same for pods in any language and for pods that nobody can modify.

## Transparent encryption between nodes

Traffic between pods on different nodes crosses the node network. Anyone with access to that network can read unencrypted packets. Cilium can encrypt this traffic without any change in the applications. This is called transparent encryption. Two technologies are available:

- WireGuard, enabled with `encryption.enabled=true` and `encryption.type=wireguard`. Each node has a key pair, and the agents exchange public keys through Kubernetes annotations on the node objects. The nodes send pod traffic through a WireGuard interface named `cilium_wg0`. WireGuard is part of the Linux kernel from version 5.6.
- IPsec, enabled with `encryption.type=ipsec`. It uses a pre-shared key that you store in a Kubernetes Secret, which the agents read. IPsec works on older kernels, and it needs key management that you perform yourself, including rotation.

Both technologies encrypt traffic between pods on different nodes. Traffic between two pods on one node does not leave the node, so it is not encrypted by this feature.

## Check the state

The agent reports whether encryption is on:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep -i encryption
```

On a default installation the line says that encryption is disabled. After you enable WireGuard on a cluster whose kernel supports it, the line names the mode, and the node has a `cilium_wg0` interface. A `kind` playground shares the kernel of your machine, so the result depends on the host kernel. Read the line, and do not assume that it changes.

You can enable it with a Helm upgrade that follows the same pattern as before:

```sh
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set encryption.enabled=true --set encryption.type=wireguard
```

The agents restart, and traffic between nodes continues during the change. Check `cilium-dbg status` on each node afterwards.

## What you now know

Identity-based policy keeps rules stable when pods change address, the eBPF program enforces them at the pod interface without a proxy in the pod, and WireGuard or IPsec encrypts traffic between nodes without any change in the applications. Together with the earlier benefits, this completes the case for eBPF as a datapath: fast lookups, safe updates, visible traffic and enforced identity.

## Common pitfalls

> [!WARNING]
> Encryption protects traffic between nodes and not traffic inside one node. It does not replace network policy: encrypted traffic can still be unwanted traffic. For IPsec, plan key rotation before you enable it. Check the kernel version of every node before you choose WireGuard.
