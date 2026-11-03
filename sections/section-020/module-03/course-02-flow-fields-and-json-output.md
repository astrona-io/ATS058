---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Flow Fields And JSON Output

A text line is good for a person, but a script needs fields with names. The JSON output of Hubble gives every flow as an object with the same structure. This part explains the fields you will use most and shows how to pull values out of the output with a command line tool.

## The structure of a flow

With `-o json` each line is a JSON object with a `flow` key. Inside it you find these fields:

- `verdict`: the decision, for example `FORWARDED` or `DROPPED`.
- `drop_reason_desc`: the reason name for a dropped flow, for example `POLICY_DENIED`.
- `source` and `destination`: the endpoints. Each has `namespace`, `pod_name`, `labels` and an `identity`, the numeric security identity.
- `IP`: the source and destination addresses.
- `l4`: the protocol and the ports, for example `TCP` with `source_port` and `destination_port`.
- `traffic_direction`: `INGRESS` or `EGRESS` from the point of view of the endpoint that reported it.
- `is_reply`: true for packets that answer an earlier packet.
- `Type` and `event_type`: the kind of event, such as a trace or a drop.

The same request produces several flows, because each hop reports its own event. A request from the `shuttle` pod to the `probe` pod can produce a flow on the egress side of the client and another on the ingress side of the server, plus the reply flows.

## Extract values with jq

`jq` is a command line JSON processor. The pipe below prints the pod names and the port of every dropped flow. The `hubble observe` command runs in the agent. The pipe runs on your machine, so `jq` must be installed there:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --namespace starfleet --verdict DROPPED --last 20 -o json \
  | jq -r '.flow | [.source.namespace, .source.pod_name, .destination.pod_name, .l4.TCP.destination_port, .drop_reason_desc] | @tsv'
```

Each output row has the source namespace, the source pod, the destination pod, the destination port and the drop reason. The port is 8080 and not 80: the socket program translates the Service address before the policy decision, so the policy sees the pod port. If a field is missing, `jq` prints `null` for it.

## Count instead of read

For an answer such as "how many requests did the policy deny", count the lines:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --namespace starfleet --verdict DROPPED --last 100 -o json | jq -s 'length'
```

The `-s` option reads all objects into one array, and `length` counts it. For counts over time, use the metrics from the previous module instead, because the flow buffer holds only recent flows.

## Use flows to find a policy mistake

When a connection fails, the flow tells you where to look. A DROPPED flow with the reason `POLICY_DENIED` means a policy denies the connection: compare the source identity and the destination port in the flow with the rule. If you see no flow at all, the packet did not reach a hook that reports events, and the cause is before the datapath, for example a wrong Service name. A FORWARDED flow with no reply points to the application or to a missing return path.

## What you now know

A flow is a structured record with a verdict, endpoints with identities, addresses, ports and a reason. JSON output lets you extract exactly the fields you need and count them. The next two parts leave Hubble and look at the features that eBPF enables around the datapath.

## Common pitfalls

> [!WARNING]
> Do not parse the default text output in a script, because its format can change between releases; use JSON. One request creates several flows, so a count of flows is not a count of requests. A drop on the destination side shows the pod port, not the Service port.
