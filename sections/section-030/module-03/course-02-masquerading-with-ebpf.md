---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Masquerading With eBPF

A pod IP address is usually not routable outside the cluster. When a pod connects to a host on the internet or on the company network, the node must replace the source address with its own, so the reply finds its way back. This replacement is called masquerading. This part explains how it works with iptables, how Cilium does it in eBPF and how to check which one a cluster uses.

## What masquerading does

Masquerading is a form of source network address translation (SNAT). The node rewrites the source address of a packet that leaves the cluster to the address of the node interface. The connection tracking entry stores the translation, and the node rewrites the destination of the reply back to the pod address.

Traffic inside the cluster is not masqueraded. The node must therefore know which destinations are inside the cluster. For this, Cilium uses the native routing CIDR, set with `ipv4NativeRoutingCIDR`. A destination inside that range is not translated.

## The iptables implementation

By default, Cilium masquerades with iptables. It installs the chain `CILIUM_POST_nat` in the `nat` table, with a rule for packets from the pod range to destinations outside the range. The rule jumps to `MASQUERADE`. This implementation is simple and works on old kernels. It uses netfilter and the connection tracking of netfilter, with the limits from the earlier modules.

## The eBPF implementation

With `bpf.masquerade=true`, an eBPF program on the node interface performs the translation. It looks up the destination in a map to decide if it is inside the cluster, rewrites the source address and keeps the translation in an eBPF NAT map. The packet does not pass the netfilter NAT rules of Cilium. This is faster because the program runs earlier and it avoids netfilter connection tracking for this traffic.

The eBPF masquerading needs more features from the kernel and from the agent. In many releases it needs Cilium to handle NodePort traffic too, which means that kube-proxy replacement must be on. If a dependency is missing, the agent writes an error to its log and does not start. Always read the system requirements of your release before you turn it on.

## Check the mode

The agent status shows the masquerading mode:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep Masquerading
```

The line starts with `Masquerading` and names the mode. `IPTables` means the default implementation. `BPF` means the eBPF implementation. The value is stored in the ConfigMap `cilium-config` as the key `enable-bpf-masquerade`:

```sh
kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.enable-bpf-masquerade}{"\n"}'
```

To see the iptables rules of the default implementation, list the Cilium chain in the NAT table:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- iptables-save -t nat | grep CILIUM_POST_nat
```

Switch to the eBPF implementation with a Helm upgrade and restart the agents so that they read the new setting:

```sh
API_HOST=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].metadata.name}')
helm repo add cilium https://helm.cilium.io/
helm repo update
helm upgrade cilium cilium/cilium --version 1.20.2 --namespace kube-system --reuse-values \
  --set bpf.masquerade=true --set kubeProxyReplacement=true \
  --set k8sServiceHost="$API_HOST" --set k8sServicePort=6443 --wait --timeout 300s
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

Read the status again. It should now show the `BPF` mode. The NAT map holds the active translations. Print it after a pod has sent traffic outside the cluster range:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg bpf nat list
```

## Where the traffic goes

The agent decides on each packet whether the destination is a cluster address. Pod to pod traffic and pod to node traffic stay untranslated. Traffic to an external address is translated. If the cluster uses overlay routing, the encapsulated traffic between nodes carries the pod addresses, and only the traffic that leaves the cluster is masqueraded.

## What you now know

Masquerading rewrites the source address of traffic that leaves the cluster, so replies return to the node. Cilium does it with iptables by default and with an eBPF program when `bpf.masquerade=true`. You can read the mode in the agent status, the setting in `cilium-config` and the translations in the NAT map. The question that remains is how to apply policy to the node itself and not only to pods.

## Common pitfalls

> [!WARNING]
> Do not turn on eBPF masquerading without reading its requirements for your release: a missing dependency stops the agent. A wrong `ipv4NativeRoutingCIDR` masquerades traffic that should keep its pod address, or the reverse. Always restart the agents after the upgrade, because they read the setting at start.
