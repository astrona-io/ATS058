---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Connection Tracking And NAT Debugging

A Service translation works only if the reply of a backend returns to the client with the right address. The kernel connection tracking table, called conntrack, remembers each translation for exactly this reason. When a cluster has odd failures, such as dropped connections or resets, conntrack and the NAT rules are the first places to look. This part explains what conntrack stores, which limits it has, and how to read both conntrack and the rule counters.

## What conntrack stores

Netfilter tracks every connection that passes through a node. An entry in the conntrack table holds the original direction (source and destination address and port), the reply direction, the protocol, the state and a timeout. When kube-proxy rewrites a destination from a cluster IP to a pod IP, the entry stores both directions. The reply packet from the pod matches the entry, and the kernel rewrites its source back to the cluster IP.

Only the first packet of a connection walks the NAT chains. The later packets match the entry directly. This is the reason that a change of the rules does not affect connections that are already open.

## Limits of the table

The table has a fixed maximum size, set by the kernel parameter `net.netfilter.nf_conntrack_max`. The current count is in `net.netfilter.nf_conntrack_count`. When the count reaches the maximum, the kernel drops packets that would create a new entry and writes the message `nf_conntrack: table full, dropping packet` to the kernel log.

Entries also stay in the table after a connection ends. A TCP entry in the `TIME_WAIT` state lives for 120 seconds by default. A UDP entry lives for 30 seconds, or longer for a stream. A node that opens many short connections fills the table with entries that no longer matter.

A stale UDP entry is a known problem for Services. If a client sends UDP packets to a cluster IP and the backend pod is deleted, the old entry still points to the deleted pod. The client keeps sending to it until the entry expires, unless something deletes the entry. kube-proxy deletes the entries of removed UDP backends for this reason.

## Read the counters

The cluster agent pod runs on the host network, so reading the kernel parameters in it shows the values of the node:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cat /proc/sys/net/netfilter/nf_conntrack_count
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cat /proc/sys/net/netfilter/nf_conntrack_max
```

If the files do not exist, the conntrack module is not loaded on that node. Compare the two numbers. A count close to the maximum is the sign of a full table. On a real node, the `conntrack` tool prints more: `conntrack -S` shows per-CPU statistics such as `insert_failed` and `drop`, and `conntrack -L` lists the entries. The tool is part of the `conntrack-tools` package and is often not installed.

## Read the NAT rules and their counters

The rule counters show which rules matched. The option `-c` of `iptables-save` adds the packet and byte counters to each rule:

```sh
PROXY=$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$PROXY" -- iptables-save -c -t nat | grep 'starfleet/probe'
```

The prefix `[packets:bytes]` of each line tells you how many packets matched it. Send a request from the `shuttle` pod and run the command again. The counter of the rule for the `probe` Service increases by the packets of the new connections. The counter increases only for the first packet of each connection, because of conntrack.

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/status/200
```

The human-readable view is `iptables -t nat -L KUBE-SERVICES -n -v`. It prints the packet count in the first column and the comment of each rule at the end.

## A short method for a failing Service

Work from the client to the backend and check one layer at a time.

1. Read the Service and its EndpointSlices with `kubectl get service` and `kubectl get endpointslices`. A Service without ready endpoints gets a reject rule in kube-proxy, so the client sees a refused connection.
2. Find the Service rule on the node of the client and check that the counter increases on a new request.
3. Check the conntrack count against the maximum.
4. Check the kernel log of the node for `nf_conntrack` messages.

Cilium replaces the translation with maps that you read with `cilium-dbg`, and it keeps its own connection tracking tables for the same purpose. The later modules compare these tables with the ones in this part.

## What you now know

Conntrack stores the translation of each connection in both directions, so the reply returns correctly and only the first packet walks the NAT chains. The table has a fixed size, and a full table drops new connections. You can read the count and the maximum, and you can read rule counters with `iptables-save -c`. The open question is how Cilium keeps the same state without netfilter, which the next module answers.

## Common pitfalls

> [!WARNING]
> Do not raise `nf_conntrack_max` without checking the memory of the node, because every entry uses kernel memory. Do not flush the conntrack table on a production node to fix a problem: this resets every open connection. A rule counter that does not increase for a Service does not prove that the rule is wrong, because an existing connection is matched by conntrack and does not reach the rule.
