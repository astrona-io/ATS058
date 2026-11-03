# Replace kube-proxy With Cilium

The cluster runs kube-proxy in iptables mode next to Cilium, which is installed without kube-proxy replacement. The team wants Cilium to handle Services with eBPF and wants kube-proxy and its rules gone.

## Task

1. Enable kube-proxy replacement on the existing Cilium release. Cilium must reach the API server directly, so set the API server host and port in the release values. Keep the other values.
2. Restart the Cilium agents so that they run with the new setting.
3. Delete the `kube-proxy` DaemonSet and its ConfigMap in `kube-system`.
4. Remove the iptables rules that kube-proxy left on every node.
5. Show that the `shuttle` pod still reaches the `probe` Service and that the service map lists all three `probe` pods.

## Constraints

- Use `--reuse-values` so earlier settings stay.
- Remove only the kube-proxy rules. Do not flush the other iptables rules.
- The API server of the lab cluster listens on port 6443 on the control plane node.

## Check your work

Run `astrona submit`.
