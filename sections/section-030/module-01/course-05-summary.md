---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Summary

kube-proxy in iptables mode translates Service addresses with rules in the NAT table of netfilter. The entry chain `KUBE-SERVICES` has one rule for each Service port. It jumps to a `KUBE-SVC` chain for the Service, which picks a backend with random probabilities and jumps to a `KUBE-SEP` chain. That chain rewrites the destination to the pod address and port. Connection tracking stores the translation, so only the first packet of a connection walks the chains. The hash in a chain name differs between clusters, so the comment of the rule is the stable key.

The model has limits that grow with the cluster. The rule lists grow with the number of Services and backends on every node, and the entry chain is read in order with no index. Each sync loads a larger table under a lock, so changes take longer to become effective. The connection tracking table has a fixed size and fills with short connections. Policy based on addresses needs a rule update for each pod change, and the packet carries no identity of the sender.

The model also gives little insight. Counters exist, but the information about which pod talked to which pod and why a packet was dropped needs extra logging or a packet capture. None of these limits is a problem for a small cluster, and all of them are measurable in a large one.

Key facts:

- `iptables-save -t nat` in a kube-proxy pod shows the Service rules of that node.
- The number of rules is the same on every node.
- Sync cost depends on the size of the table.
- The conntrack table has a maximum size that the node sets.

<!-- astrona:playground:destroy -->
