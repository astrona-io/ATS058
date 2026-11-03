# Playground Guide

This playground is a private, ungraded Kubernetes cluster for the reading pages of this module. It is a two-node `kind` cluster, which means the nodes run as containers on your machine, and it uses Cilium as the network plugin instead of the default one.

## What runs in the cluster

- Cilium, with one agent pod on each node (the `cilium` DaemonSet in `kube-system`) and the Cilium operator.
- No Hubble at the start. Enable it with a Helm upgrade when a page asks for it.
- The example application. In the `starfleet` namespace the `probe` Deployment serves HTTP on port 8080 behind a Service on port 80 (one replica). A `shuttle` pod in `starfleet` and a `drifter` pod in `outpost` are curl clients that stay running.

You are the cluster administrator. `kubectl` already points at this cluster, and `helm` is available for chart changes.

## Useful commands

Run a command in a Cilium agent pod:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg status
```

Send a request from the `shuttle` pod to the `probe` Service:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 http://probe.starfleet.svc/status/200
```

`ds/cilium` selects one agent pod. When you need the agent of a specific node, list the pods with `kubectl -n kube-system get pods -l k8s-app=cilium -o wide` and use the pod name.

## Starting and stopping

The first start takes several minutes because the node image and the Cilium images must be pulled. The playground has a time limit and the reading pages renew it. When you finish, the module summary page removes the playground and the cluster.
