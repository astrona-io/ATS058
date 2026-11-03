---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Scaling Limits Of The iptables Model

The chains that kube-proxy writes work well for a handful of Services. The design problems appear when the cluster grows to thousands of Services and tens of thousands of pods. The limits come from how iptables stores rules, how kube-proxy writes them and how connection tracking and policy are built on IP addresses. This part names each limit, explains its cause and says what it affects.

## Rule counts grow with Services and backends

Every Service port adds one rule to the entry chain, one Service chain and as many backend chains as it has backends. A cluster with five thousand Services and an average of ten backends holds tens of thousands of chains and rules in the NAT table of every node. The number is the same on each node, because every node must be able to translate every Service.

Rules use kernel memory, and the rule set has to be copied or replaced as a whole in some operations. A large table also makes the output of `iptables-save` long and hard to read, which affects debugging more than speed.

## The entry chain is read in order

A packet for a Service is compared with the rules of the entry chain one at a time. The kernel has no index over these rules. A new connection to a Service near the end of the list passes the rules of all Services before it. Only the first packet of a connection takes this walk, but a cluster with many short connections pays it often, and the delay adds to the time to open each connection.

kube-proxy reduces the problem by splitting the entry chain by traffic type, so a packet does not read rules that cannot match. This lowers the constant, but the list still grows with the number of Services.

## Updates cost more as the table grows

When a Service or a backend changes, kube-proxy must change the rules. It builds the wanted rules in memory and loads them with `iptables-restore`, which replaces a set of rules in one transaction. A transaction is correct because no packet sees a half-written rule set. The cost depends on the size of the table, and while the transaction runs the kernel holds a lock on the table. In a large and busy cluster, kube-proxy spends a noticeable share of CPU time on syncs, and a change can take seconds to become effective. The delay between a pod becoming ready and receiving traffic is therefore longer in a big cluster.

kube-proxy syncs at a limited rate, so several changes in a short time are combined into one sync. This protects the node, but it adds delay.

## Connection tracking has a fixed table

Destination NAT depends on conntrack, whose table has a maximum number of entries. A node that runs out of entries drops new connections and writes a message to the kernel log. Services that open many short connections, such as a client that does not reuse connections or a DNS-heavy workload, fill the table faster. Each entry also stays after the connection ends, until its timeout expires. The limit is a node setting that an operator must size.

UDP traffic creates a particular problem. A request and its reply share an entry, but if a pod behind a Service disappears, a client that keeps sending to the old entry can keep sending packets to the old address until the entry expires.

## Policy based on IP addresses

Kubernetes network policy names pods by labels, but an implementation that uses iptables needs addresses. It must translate each label selector into a list of IP addresses, put them into rules or sets and update them whenever a pod starts or stops. A busy namespace changes its address list often, and each change is a rule update with the cost described above. The packet is matched against addresses, not against identity, and it does not carry the identity of the sender. Cilium replaced this model by identities that are numbers stored in maps.

## What the model does not show

iptables counts packets and bytes for each rule, but it does not record which pod talked to which pod, and it does not say why a packet was dropped, unless an administrator adds logging rules. Logging rules add to the table and write to the kernel log, so they are used only briefly. Finding the reason for a dropped connection often needs a packet capture on the node.

## Try it on the playground

You will measure the size of the NAT table on a node and see how it changes. Save the name of a kube-proxy pod and count the lines of the NAT table:

<!-- astrona:playground:renew -->

```sh
PROXY=$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$PROXY" -- sh -c 'iptables-save -t nat | wc -l'
```

Save this as `service-demo-b.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-b
  namespace: starfleet
spec:
  selector:
    app: probe
  ports:
    - name: http
      port: 80
      targetPort: 8080
```

Apply it, wait a few seconds for kube-proxy to sync and count again:

```sh
kubectl apply -f service-demo-b.yaml
kubectl -n kube-system exec "$PROXY" -- sh -c 'iptables-save -t nat | wc -l'
```

The number is higher. The difference is the entry rule, the Service chain and one backend chain with its rules for each `probe` pod. Read the new rules with the comment of the Service:

```sh
kubectl -n kube-system exec "$PROXY" -- iptables-save -t nat | grep 'starfleet/demo-b:http'
```

Next, read the size of the connection tracking table on the node, if the file is present in the pod. The first value is the number of entries, and the second one is the limit:

```sh
kubectl -n kube-system exec "$PROXY" -- sh -c 'cat /proc/sys/net/netfilter/nf_conntrack_count /proc/sys/net/netfilter/nf_conntrack_max'
```

## What you now know

The iptables model grows with the number of Services and backends: the lists get longer, the entry chain has no index, every sync loads a bigger table and conntrack has a fixed size. Policy based on addresses adds one more source of updates, and the model gives little visibility into why a packet was dropped. None of these limits breaks a small cluster, and all of them show in a large one.

## Common pitfalls

> [!WARNING]
> Do not conclude that iptables is always slow. The costs depend on the size of the cluster, the rate of change and the number of new connections. Measure the table and the sync time on your own nodes before you decide. Also, the conntrack values depend on the node kernel, and the files can be missing in a container that does not see them.
