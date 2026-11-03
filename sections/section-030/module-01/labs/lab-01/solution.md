# Solution

## Step 1: Read the cluster IP

```sh
kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}{"\n"}'
```

## Step 2: Print the NAT rules

kube-proxy runs as a DaemonSet in `kube-system`. Save the name of one of its pods and print the NAT table from inside it:

```sh
PROXY=$(kubectl -n kube-system get pods -l k8s-app=kube-proxy -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$PROXY" -- iptables-save -t nat > nat-rules.txt
grep 'starfleet/probe:http cluster IP' nat-rules.txt
```

The matching rule belongs to the chain `KUBE-SERVICES` and jumps to a chain whose name starts with `KUBE-SVC-`. That is the Service chain.

## Step 3: Count the backend chains

Replace `<CHAIN>` with the chain name from step 2. Each rule of the Service chain that jumps to a `KUBE-SEP-` chain is one backend:

```sh
grep -c -- "^-A <CHAIN> .*-j KUBE-SEP-" nat-rules.txt
```

The result should equal the number of `probe` pods, which is three.

## Step 4: Record the evidence

```sh
kubectl -n starfleet create configmap iptables-evidence \
  --from-literal=probe_cluster_ip=<CLUSTER_IP> \
  --from-literal=service_chain=<CHAIN> \
  --from-literal=backend_chain_count=3
```

Then run `astrona submit`.
