---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# Cilium Components, Custom Resources And Command Line Tools

When a Cilium cluster misbehaves, the first question is which component to look at. The agent, the operator, the CNI plugin and Hubble Relay each own a different job and a different set of logs. This part names the components again with their exact tasks, shows the Kubernetes custom resources that Cilium stores its state in, and explains the two command line tools that people mix up: `cilium-dbg` and `cilium`.

## What each component owns

The agent runs on every node and owns everything that happens on that node. It compiles and loads the eBPF programs, writes the maps, creates endpoints, enforces policy and serves the local Hubble flows. If a pod on one node has a problem and pods on other nodes do not, the agent on that node is the first place to look.

The operator runs as a Deployment with one or more replicas, and only one replica is the active leader. It handles cluster-wide work that must not run on every node. It removes `CiliumIdentity` and `CiliumEndpoint` objects that no pod uses any more. In the cluster-pool IP address management (IPAM) mode, it also hands out a pod address range to each node. IPAM (IP address management) is the process that assigns pod IP addresses. If the operator is down, existing traffic keeps flowing, but cleanup and new range allocations stop.

The CNI plugin is a binary on the node. The container runtime calls it when a pod sandbox is created or deleted. It does not keep state. It forwards the request to the local agent and returns the result.

Hubble Relay is a Deployment that connects to the Hubble server of each agent and offers one API for the whole cluster. The `hubble` command and the Hubble UI talk to Relay. Without Relay, you can still read the flows of one node directly from its agent.

## The custom resources

A custom resource is an object kind that an extension adds to the Kubernetes API with a CustomResourceDefinition. Cilium uses custom resources to share state between agents and to show it to you. These are the ones you will meet:

| Resource | What it holds | Written by |
| --- | --- | --- |
| `CiliumNode` | Node address, pod address range and health addresses of one node | The agent of that node, and the operator for ranges |
| `CiliumEndpoint` | One pod: its endpoint ID, security identity, labels and IP addresses | The agent of the pod node |
| `CiliumIdentity` | One security identity number and the label set that it stands for | The agent or the operator, depending on the identity allocation mode |
| `CiliumNetworkPolicy` | A namespaced policy | You |
| `CiliumClusterwideNetworkPolicy` | A policy without a namespace | You |

The agent reads the custom resources of other nodes to learn which identity belongs to which address. Because the state lives in the Kubernetes API, any administrator can inspect it with `kubectl`.

<!-- astrona:playground:renew -->

List the endpoints and the identities in the playground:

```sh
kubectl get ciliumendpoints --all-namespaces
kubectl get ciliumidentities
kubectl get ciliumnodes
```

Find the row of the `probe` pod. The identity column shows its number. Then find the same number in the list of identities and read the labels that belong to it:

```sh
kubectl get ciliumidentity <identity-number> -o yaml
```

Replace `<identity-number>` with the number you found. The `security-labels` field lists the labels that make up the identity, including the namespace label. This explains why two pods with the same `app` label in different namespaces have different identities.

## Cilium configuration

The agent reads its configuration from a ConfigMap named `cilium-config` in `kube-system`. When you install with Helm, each Helm value becomes a key in that ConfigMap. The agent reads the file at start, so a change needs a restart of the agent DaemonSet. Helm triggers that for you when the ConfigMap checksum changes.

```sh
kubectl -n kube-system get configmap cilium-config -o yaml
```

Look for keys such as `routing-mode`, `kube-proxy-replacement` and `enable-hubble`. Keys use lowercase words separated by hyphens, and Helm values use camel case, so the value `kubeProxyReplacement` becomes `kube-proxy-replacement`.

## cilium-dbg and cilium

Two tools have almost the same name and different jobs. `cilium-dbg` is the debug client inside the agent container. It talks to the local agent through a Unix socket, so it shows the state of one node. You run it with `kubectl exec`, as in `cilium-dbg status`, `cilium-dbg endpoint list` and `cilium-dbg bpf lb list`.

`cilium` is the Cilium command line interface (CLI). You install it on your own machine. It uses your kubeconfig, installs and upgrades Cilium, and runs cluster-wide checks, for example `cilium status` and `cilium connectivity test`. The connectivity test deploys test workloads and checks many traffic paths, so run it only on a cluster where you may create namespaces.

Older releases named the in-pod tool `cilium`. Newer releases renamed it `cilium-dbg`, so a command from an old article may need the new name.

## What you now know

The agent owns the node, the operator owns cluster-wide cleanup and allocation, the CNI plugin only forwards requests and Hubble Relay joins the flows of all nodes. Cilium keeps shared state in custom resources that you can read with `kubectl`, and it reads its settings from the `cilium-config` ConfigMap. `cilium-dbg` shows one node and `cilium` works on the cluster. The next question is how a request from one pod reaches another pod through these components and maps.

## Common pitfalls

> [!WARNING]
> Do not run `cilium-dbg` on your own machine, because it exists in the agent container. Do not edit `CiliumEndpoint` or `CiliumIdentity` objects by hand, because the agent owns them and overwrites your change. A change in the `cilium-config` ConfigMap does not apply until the agent restarts.
