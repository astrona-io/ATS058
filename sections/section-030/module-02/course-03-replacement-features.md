---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Services Features Of The Replacement

A kube-proxy replacement is only useful if it handles every Service feature that the cluster uses. If one feature is missing, the cluster needs kube-proxy again. This part lists the Service features that Cilium handles with eBPF, the Helm values that tune them, and how the agent reports which ones are active.

## The Service types

With `kubeProxyReplacement=true`, Cilium handles these Service types and address forms:

- ClusterIP: the virtual address of a Service inside the cluster.
- NodePort: a port that every node opens for the Service, in the range 30000 to 32767 by default.
- LoadBalancer: a Service that an external load balancer exposes. Cilium handles the traffic that arrives at a node from that load balancer.
- ExternalIPs: addresses listed in `spec.externalIPs` of a Service, which route to a node.
- HostPort: a `hostPort` in a pod specification, which maps a port of the node to the pod.

Each of these forms is one more entry in the service maps. A frontend with the address and port of the node, or of the external IP, points to the same backends as the cluster IP. The agent reads the Services and EndpointSlices once and builds all frontends from them.

## Backend selection

The default backend selection is random. A new connection picks a backend from the list of the Service. For large clusters, Cilium offers Maglev consistent hashing, which you turn on with `loadBalancer.algorithm=maglev`. With Maglev, each node builds the same lookup table from the backends, so two nodes pick the same backend for the same connection. This is useful when external traffic reaches different nodes for one connection, for example after a load balancer change.

## Session affinity

A Service can ask for client IP affinity with `spec.sessionAffinity: ClientIP`. All connections of one client then go to the same backend, until the timeout in `spec.sessionAffinityConfig.clientIP.timeoutSeconds` passes. The default timeout is 10800 seconds. Cilium keeps the affinity in an eBPF map, and it supports the setting for traffic from pods and for external traffic. kube-proxy does the same with the `recent` match of netfilter.

## Traffic policy

The field `spec.externalTrafficPolicy` decides what happens to external traffic.

- `Cluster` is the default. A node accepts the traffic and may send it to a backend on another node. The source address is translated, so the client address is lost, unless direct server return is used.
- `Local` sends the traffic only to backends on the same node. A node without a local backend does not answer. The source address of the client stays visible.

The field `spec.internalTrafficPolicy` does the same for traffic from inside the cluster. With `Local`, a pod reaches only a backend on its own node.

## Load balancing mode

The Helm value `loadBalancer.mode` has three settings. `snat` is the default: the receiving node translates the source address. `dsr` is direct server return, where the backend node answers the client directly. `hybrid` uses DSR for TCP and `snat` for UDP. DSR needs a network that allows the answer to leave from another node than the one that received the request.

## Early handling with XDP

`loadBalancer.acceleration=native` moves the NodePort lookup to the XDP hook in the driver of the network interface, before the kernel builds the packet structure. The driver must support XDP in native mode. The default is `disabled`.

## Read the active features

The agent prints the features of the replacement in the verbose status. Use the playground to look at it. The output of your cluster may show a different set of values:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status --verbose
```

Find the section that starts with `KubeProxyReplacement Details`. It lists the mode, whether socket load balancing is on, the backend selection (random or Maglev), the session affinity support, the supported Service types and the XDP acceleration setting. Print the Services that the agent handles, with their types:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg service list
```

Each row has an ID, the frontend address, the type (for example `ClusterIP` or `NodePort`) and the backend addresses. A NodePort Service has one row for the cluster IP and rows for the node addresses. If the cluster has no NodePort Service yet, create one in the playground and list the Services again:

```sh
kubectl -n starfleet expose deployment probe --name=probe-np --type=NodePort --port=80 --target-port=8080
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg service list
```

## What you now know

The replacement handles ClusterIP, NodePort, LoadBalancer, ExternalIPs and HostPort. You can tune the backend selection, the load balancing mode and the XDP acceleration with Helm values, and the traffic policy fields of the Service decide whether the client address survives. The verbose status and the service list show what is active. The open question is how to prove that a cluster is healthy after the switch, and what to do when it is not.

## Common pitfalls

> [!WARNING]
> `externalTrafficPolicy: Local` makes a node without a local backend drop the traffic, so the load balancer in front must run health checks. DSR does not work on every network. Do not turn on XDP acceleration before you check that the network driver supports native XDP. Delete the NodePort Service `probe-np` after the exercise if you keep the playground.
