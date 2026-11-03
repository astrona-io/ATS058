# Turn On eBPF Masquerading

The cluster masquerades traffic that leaves the cluster with iptables rules. The platform team wants the eBPF implementation, which keeps the translations in an eBPF map.

## Task

1. Upgrade the Cilium release so that eBPF masquerading is on. This mode needs Cilium to handle NodePort traffic, so also enable kube-proxy replacement. Cilium must reach the API server directly, so set the API server host and port in the release values. Keep the other values.
2. Restart the Cilium agents so that they run with the new settings.
3. Show that every agent reports the `BPF` masquerading mode and that the `shuttle` pod still reaches the `probe` Service.
4. Record the result in a ConfigMap named `masquerade-evidence` in `starfleet`:

| Key | Value |
| --- | --- |
| `masquerade_mode` | The mode that the agent status reports, written exactly as `BPF` |
| `agent_count` | The number of Cilium agent pods in the cluster |

## Constraints

- Use `--reuse-values` so earlier settings stay.
- Do not delete kube-proxy in this lab.
- The API server of the lab cluster listens on port 6443 on the control plane node.

## Check your work

Run `astrona submit`.
