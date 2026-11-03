---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Select Flows With The Hubble Command Line

A busy node produces thousands of flows each minute, and reading them all is not possible. The `hubble` command line client can select exactly the flows that answer a question. This part explains where the client gets its data and the filters that you will use most often.

## Where the data comes from

The Hubble server inside each agent keeps a ring buffer of the most recent flows of its node. Running `hubble observe` inside an agent container therefore shows only the flows of that node. Hubble Relay connects to all agents and offers one endpoint for the whole cluster. The client that you install on your own machine connects to Relay, usually through a port-forward. The Cilium CLI can start it for you:

```sh
cilium hubble port-forward &
hubble status
```

The status command prints whether the server is reachable and how many flows it holds. In this playground you can also use the client that is already in the agent container, which is what the commands below do. Add `--last 50` to select the 50 most recent flows, or `--follow` to stream new flows as they happen.

## Filters

Each filter narrows the result. Several filters together select flows that match all of them.

| Filter | What it selects |
| --- | --- |
| `--namespace starfleet` | Flows where the source or the destination is in the namespace |
| `--pod starfleet/probe-xyz` | Flows where the pod is the source or the destination |
| `--from-pod outpost/drifter-abc` and `--to-pod starfleet/probe-xyz` | Flows with that source and that destination |
| `--verdict DROPPED` | Flows with the verdict FORWARDED, DROPPED, ERROR or AUDIT |
| `--protocol TCP` | Flows of a protocol, such as TCP, UDP, ICMPv4 or http |
| `--to-port 8080` | Flows with that destination port |
| `--type drop` | Flows of an event type such as `trace`, `drop` or `policy-verdict` |

A pod filter needs the full pod name, which you can print with `kubectl get pods`. The name format is the namespace, a slash and the pod name. If you give only a prefix, the filter matches pods whose name starts with it.

## Select the dropped flow

Send one request from each client first:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/status/200
kubectl -n outpost exec deploy/drifter -- curl -s -m 5 -o /dev/null http://probe.starfleet.svc/status/200
```

Then ask only for dropped flows in the `starfleet` namespace:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --namespace starfleet --verdict DROPPED --last 20
```

Every line that this command prints has the verdict DROPPED. If the list is empty, the flow is on the other node: list the agents with `kubectl -n kube-system get pods -l k8s-app=cilium -o wide` and run the command in the agent on the node of the `probe` pod.

## Choose an output format

The default output has one line per flow. The option `-o compact` prints a shorter line, `-o dict` prints a multi-line block for each flow and `-o json` prints one JSON object per line. Use compact output to scan and JSON to process.

## What you now know

The client reads the flow buffer of one agent or of the whole cluster through Relay, and the filters select flows by namespace, pod, verdict, protocol, port and event type. The open question is what is inside a flow and how to use those fields in a script.

## Common pitfalls

> [!WARNING]
> An agent keeps only recent flows, so an old event can be gone. A filter that names the wrong pod prints nothing and gives no error. Flows from a node appear only in the agent of that node unless you go through Relay.
