---
draft: true
exam_objectives:
- Understand the Role of eBPF in Cilium
---
# Agent Health, Endpoints And The Right Node

A Cilium problem is almost always local to one node. If you run a command in the wrong agent pod, you see the state of a different node and draw the wrong conclusion. This part teaches how to pick the agent of the right node, how to read its health and how to read the endpoint of a pod.

## Pick the agent of the node that matters

Every node runs one agent pod. The shortcut `ds/cilium` that earlier examples use selects one agent pod of the DaemonSet, and not necessarily the one on the node you care about. For a real investigation, find the node of the pod first.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get pods -l app=probe -o wide
kubectl -n kube-system get pods -l k8s-app=cilium -o wide
```

The first command shows the `NODE` column of the `probe` pod. The second command lists the agent pods with their nodes. The agent pod with the same node name is the one that has the endpoint of `probe`. You can also ask Kubernetes directly with a field selector:

```sh
kubectl -n kube-system get pods -l k8s-app=cilium --field-selector spec.nodeName=<node-name> -o name
```

Replace `<node-name>` with the node name from the first command. The rest of this module assumes that you set a shell variable with the agent pod name, so commands stay short:

```sh
AGENT_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium --field-selector spec.nodeName=<node-name> -o jsonpath='{.items[0].metadata.name}')
```

## Read the health of the agent

The command `cilium-dbg status` prints a summary of the agent. It reports the state of the Kubernetes connection, the datapath mode, the controllers, the number of endpoints and the state of Hubble. Add `--brief` for a single line that says whether the agent is healthy, which is useful in scripts.

```sh
kubectl -n kube-system exec $AGENT_POD -c cilium-agent -- cilium-dbg status
```

Read three areas. The Kubernetes line must say that the agent is connected. The controller line shows how many background tasks fail, and the failing ones are named in the verbose output. The proxy and Hubble lines show whether the optional components run. A healthy agent can still have a broken endpoint, so the next step goes deeper.

## List the endpoints of the node

An endpoint is the Cilium object for one pod, one host network entity or one other workload on the node. The list shows one row per endpoint with its numeric ID, the policy state in each direction, the security identity, the labels and the IP address.

```sh
kubectl -n kube-system exec $AGENT_POD -c cilium-agent -- cilium-dbg endpoint list
```

Find the row of the `probe` pod by its labels or its IP address. Read four columns. The endpoint ID is a small number that is unique on this node, and many later commands use it. The two policy columns, for ingress and egress, say whether policy enforcement is enabled. The identity column shows the number that policy compares. The endpoint state, shown in the status column, should be `ready`.

The ID in this list is not the identity. The ID names the endpoint on this node only, and a different node gives the same pod a different ID if the pod moves. The identity names the set of labels and is the same on every node.

## Read one endpoint in detail

To see the full state of one endpoint, use the endpoint ID:

```sh
kubectl -n kube-system exec $AGENT_POD -c cilium-agent -- cilium-dbg endpoint get <endpoint-id>
```

The output is JSON. It lists the labels, the identity, the addresses, the interface name and index on the node, the policy revision and the state of the build of its programs. When a pod does not receive traffic after a policy change, compare the policy revision of the endpoint with the revision that the agent reports in `cilium-dbg status`. An endpoint that is behind the agent has not yet loaded the new policy.

The same facts exist in Kubernetes as the `CiliumEndpoint` object. It shows the endpoint ID and the identity, but it does not show the policy revision or the state of the programs. Use `kubectl` for a cluster-wide view and the agent for the detail on one node.

```sh
kubectl -n starfleet get ciliumendpoint
```

## Related checks of the whole cluster

To see the health of all nodes at once, ask an agent for its view of the cluster:

```sh
kubectl -n kube-system exec $AGENT_POD -c cilium-agent -- cilium-dbg status --all-health
```

The output lists the other nodes and says whether the agent can reach them. A node that is not reachable explains why pods on that node fail only from some other nodes.

## What you now know

You can find the agent of the node that runs a pod, read the status of the agent and read the endpoint list with the ID, the policy state and the identity. You know that the endpoint ID is local to a node and that the identity is shared. The question still open is how the agent knows the identity of a remote address, which the IP cache answers.

## Common pitfalls

> [!WARNING]
> Do not use `ds/cilium` for a node-specific investigation, because it can select the agent of another node. Do not mix up the endpoint ID with the identity number. An endpoint list that is correct on the node of the client can still be wrong on the node of the server, so look at both nodes when a request crosses nodes.
