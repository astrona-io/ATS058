---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Bandwidth Manager And How To Measure The Benefits

Marketing text about eBPF often promises large speed gains, and the real gain depends on the kernel, the hardware and the workload. A learner and an operator both need a method to check a claim on a cluster. This part first covers one more feature that eBPF makes possible, the bandwidth manager, and then gives a method to measure any of the benefits and to avoid misleading results.

## The bandwidth manager

Kubernetes lets a pod request an upper limit for its outgoing traffic with the annotation `kubernetes.io/egress-bandwidth`. Many network plugins ignore the annotation. Cilium can enforce it with the bandwidth manager, which you enable with the Helm value `bandwidthManager.enabled=true`.

The bandwidth manager does not queue packets in a shared queue on the interface. Each packet receives a departure time (EDT, earliest departure time) that eBPF writes into the packet on the pod interface. The kernel fair queueing scheduler (`fq`) on the network device then sends each packet at or after that time. The programs spread the packets of a pod over time instead of letting a burst fill the queue of the interface. Pods that stay under their limit are not slowed down.

Two points define the scope. The limit applies to egress traffic of the pod, meaning traffic that leaves the pod. Cilium does not enforce the `ingress-bandwidth` annotation. The setting `bandwidthManager.bbr=true` also switches the congestion control of the pods to BBR (Bottleneck Bandwidth and Round-trip propagation time). It needs a recent kernel, so check the system requirements of your release first.

## Read the state

The agent reports whether the feature is active:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep -i bandwidth
```

The line names the bandwidth manager and says whether it is disabled or in use. A pod asks for a limit with an annotation in its pod template:

```yaml
metadata:
  annotations:
    kubernetes.io/egress-bandwidth: "10M"
```

After a pod starts with this annotation, a rate limit for its endpoint appears in the datapath. The agent applies the limit when it creates the endpoint, so a running pod must be recreated to receive a new value.

## A method to measure a benefit

To say that a feature helps, measure the same workload with and without it, under the same conditions. Use this method:

1. State the claim in a measurable form, for example "the time to open a connection to a Service does not grow with the number of Services" or "a pod cannot send more than 10 Mbit per second".
2. Choose a tool that matches the claim. `curl` with `-w` timing variables measures connection and total time. `iperf3` measures throughput between two pods. `hubble observe` and the Hubble metrics count flows and drops.
3. Change one setting only, for example the kube-proxy mode or the load balancing algorithm.
4. Repeat each measurement several times and compare the spread, not a single value.

For example, to measure the time of one request from the `shuttle` pod to the `probe` Service, run:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w 'connect=%{time_connect} total=%{time_total}\n' http://probe.starfleet.svc/status/200
```

The command prints two times in seconds. On a two-node test cluster the numbers are tiny and noisy, and that is the lesson: a few Services show no difference between the models. The difference appears at the scale that the earlier chapters on lookups and updates describe, with thousands of Services and frequent changes.

## Limits of a test cluster

A `kind` cluster runs every node as a container on one machine, and all nodes share the kernel of the host. The kernel features that a node can use are the features of the host kernel. The virtual network between the nodes is not a physical network, so features that need hardware support, such as XDP in a network driver, give no realistic result. Use a playground to learn the commands and the output, and use a cluster with real nodes to judge performance.

## What you now know

The bandwidth manager enforces the egress bandwidth annotation with departure times set by eBPF and the fair queueing scheduler. More important is the method: state the claim, change one setting, repeat the measurement and know what the test environment cannot show. The next module turns to the operational benefits of eBPF: seeing traffic and updating the datapath safely.

## Common pitfalls

> [!WARNING]
> A single measurement on a small cluster proves nothing. Do not compare two clusters that differ in more than one setting. Do not expect the ingress bandwidth annotation to work: Cilium enforces only the egress limit. A pod must be recreated to receive a changed annotation.
