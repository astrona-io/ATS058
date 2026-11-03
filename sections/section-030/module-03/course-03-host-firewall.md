---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# The Host Firewall

Network policy for pods does not protect the node itself. The node runs the kubelet, SSH and other services, and these listen on node addresses. On many platforms the node firewall is a separate set of iptables rules, written by hand or by another tool. This part explains how Cilium applies policy to the node with the same model as for pods, and how to avoid a lockout.

## What the host firewall is

The host firewall is a Cilium feature that attaches eBPF programs to the network interfaces of the node and enforces policy for traffic to and from the node. The node gets its own endpoint, called the host endpoint, and its own identity, `host`. Policy rules select the node with a `nodeSelector` and not with an `endpointSelector`. These policies are cluster-wide, so they use the kind `CiliumClusterwideNetworkPolicy`.

The feature is off by default. You turn it on with the Helm value `hostFirewall.enabled=true`, and the agents restart to apply it. The agent status then reports the host firewall as enabled.

## A policy for a node

A node policy looks like a pod policy with a different selector. This example allows the kubelet and SSH ports from anywhere and denies the rest of the ingress to nodes that have the label `node-role.kubernetes.io/worker`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumClusterwideNetworkPolicy
metadata:
  name: worker-ingress
spec:
  nodeSelector:
    matchLabels:
      node-role.kubernetes.io/worker: ""
  ingress:
    - toPorts:
        - ports:
            - port: "22"
              protocol: TCP
            - port: "10250"
              protocol: TCP
```

The example is incomplete for a real cluster. A node also needs its traffic to the API server, to the other nodes, to the overlay port and to health checks. A missing rule drops that traffic and can make the node unreachable.

## Prevent a lockout with audit mode

The host endpoint has an audit mode. In this mode, the agent evaluates the policy but does not drop packets. It reports the packets that the policy would have dropped. You enable it for the host endpoint, find its ID in the endpoint list and set the option:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg endpoint list
```

The host endpoint has the label `reserved:host`. Take its ID from the first column and turn audit mode on:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg endpoint config <HOST_ENDPOINT_ID> PolicyAuditMode=Enabled
```

Replace `<HOST_ENDPOINT_ID>` with the ID. Then watch the verdicts of the policy for a while:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg monitor -t policy-verdict
```

A line with the verdict `audit` marks traffic that the policy would drop. Add rules until the audit lines show only traffic that you want to block. Then turn off audit mode with `PolicyAuditMode=Disabled`.

## Compared with iptables rules on the node

A node firewall that uses iptables matches addresses and ports in a rule list. It has no knowledge of the identity of the sender. With the Cilium host firewall, a rule can select a pod, a node or a reserved entity by identity. The entities `host`, `remote-node` and `kube-apiserver` let a rule name the other nodes and the API server without a list of addresses. These rules stay correct when nodes join or leave.

## What you now know

The host firewall applies Cilium policy to the node with `CiliumClusterwideNetworkPolicy` and a `nodeSelector`. It is off by default. The audit mode on the host endpoint shows what a policy would drop before it drops anything. The last question is how the two platforms compare overall, and which iptables rules stay on a node that runs Cilium.

## Common pitfalls

> [!WARNING]
> A host policy that is missing the rules for the API server, the other nodes or SSH can cut you off from the node, and you may need the console of the machine to recover. Always start in audit mode and test on one node. Test host policies only on a throwaway cluster such as the playground.
