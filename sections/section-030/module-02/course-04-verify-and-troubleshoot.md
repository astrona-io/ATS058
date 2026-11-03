---
draft: true
exam_objectives:
- eBPF-based Platforms versus IPtables-based Platforms
---
# Verifying And Troubleshooting The Replacement

After the migration, you must be able to say with evidence that Cilium handles Services and that kube-proxy no longer does. When a Service fails after the change, you need a fixed order of checks. This part gives a verification checklist and a troubleshooting order, and it names the failures that are most common.

## What to verify

A complete verification has four checks, and each one answers a different question.

1. The configuration. The key `kube-proxy-replacement` in the ConfigMap `cilium-config` is `true`. This shows what the agents should do.
2. The agents. Every agent reports `KubeProxyReplacement: True` in `cilium-dbg status`. This shows what the agents do. An agent that did not restart still runs with the old setting.
3. The state. The services appear in `cilium-dbg bpf lb list`, with all backends. This shows what the kernel programs use.
4. The traffic. A real request from a pod to a ClusterIP, and a request from outside to a NodePort, succeed.

Run the first three checks on the playground:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system get configmap cilium-config -o jsonpath='{.data.kube-proxy-replacement}{"\n"}'
kubectl -n kube-system get pods -l k8s-app=cilium -o name
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status | grep KubeProxyReplacement
```

Repeat the status command for each agent pod, because `ds/cilium` selects only one. Then compare the backends in the map with the Kubernetes objects:

```sh
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg bpf lb list
```

The addresses of the three `probe` pods must appear as backends. A backend in Kubernetes that is missing in the map means that the agent did not apply the update.

## Check that kube-proxy is not in the way

Two programs that both rewrite Service traffic can conflict. Check that no kube-proxy pod runs and that no Service rules remain:

```sh
kubectl -n kube-system get pods -l k8s-app=kube-proxy
kubectl -n kube-system exec ds/cilium -c cilium-agent -- sh -c 'iptables-save | grep -c KUBE-SVC'
```

The first command should list no pod. The second prints the number of lines with `KUBE-SVC`, which should be 0 after the cleanup of the node.

## A fixed order of checks for a failing Service

When a Service does not answer, go from the control plane to the datapath, and stop at the first check that fails.

1. Does the Service have ready endpoints? Run `kubectl get endpointslices`. No endpoints means a selector or readiness problem and not a Cilium problem.
2. Does the agent know the Service? Run `cilium-dbg service list` and look for the frontend address.
3. Is the frontend in the map? Run `cilium-dbg bpf lb list`.
4. Is the packet dropped? Run `cilium-dbg monitor -t drop` in the agent pod of the node while you send a request. A drop line names the reason, for example a policy denial.
5. Is there a connection tracking entry? Run `cilium-dbg bpf ct list global` and look for the client and backend addresses.
6. Does the agent report errors? Run `kubectl -n kube-system logs ds/cilium -c cilium-agent` and search for lines with the level `error` or `warning`.

If the Hubble command line tool is available, `hubble observe --to-pod starfleet/probe` shows the verdict of each flow, which makes steps 4 and 5 shorter.

## Common failures

- The agent does not start after you set `kubeProxyReplacement=true`. The agent log names the missing kernel feature or the missing API server address. Set `k8sServiceHost` and `k8sServicePort`, or use a newer kernel.
- Services work for pods but not from outside. Check `externalTrafficPolicy`, the node firewall and the node port range.
- Old rules answer. A node still has `KUBE` rules because the cleanup ran on only one node.
- A Service works until the agent restarts. The agent may have started with an old setting. Compare the ConfigMap with the status of each agent.
- Backends are missing in the map. The agent lost its connection to the API server. Read the agent log.

## What you now know

You can verify the replacement in four layers: configuration, agent status, map state and traffic. You can also check that no kube-proxy rule remains. For a failing Service, you check endpoints first, then the agent view, the map, the dropped packets and the agent log. This closes the module on the replacement. The next module looks at other parts of the platform that used iptables and now use eBPF.

## Common pitfalls

> [!WARNING]
> Do not treat the Helm value as proof. Only the agent status and the map show the real state. Do not run the cleanup of the iptables rules before the agents report the replacement, because the Services would then have no handler. When you read `cilium-dbg monitor` output, remember that it shows the events of one node only.
