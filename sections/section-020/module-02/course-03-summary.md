---
draft: true
exam_objectives:
- eBPF Key Benefits
---
# Summary

The eBPF programs of Cilium already run on the path of every packet and know the identities and the policy verdict. They write events to a kernel buffer, and the Cilium agent turns them into flows. The Hubble server in each agent serves the flows of its node, Hubble Relay combines the flows of all nodes, and the `hubble` client reads them. A flow shows the source, the destination, the verdict and for a drop the reason, so a policy drop is distinguishable from other drops. Hubble is a setting of the Helm chart, and changing it restarts the agents.

The kernel verifier rejects programs that could read invalid memory or never end, so a faulty program does not run. Cilium needs no kernel module and no reboot. A new program replaces an old one at the hook in one step, and Service and policy changes are writes to single map entries. The verifier proves safety and not intent, so a wrong policy still breaks traffic.

The kernel holds the programs, and Cilium pins its maps in the BPF file system. When the agent stops, forwarding continues with the state that existed, and changes wait until the agent returns and writes the difference. Long outages let the maps drift, and a node reboot clears the BPF file system.

Key facts:

- Hubble flows are limited to a ring of recent events per node.
- `hubble observe` in an agent pod shows the flows of that node.
- A DROPPED verdict names its reason, and Policy denied is the reason for a policy drop.
- Restart agents one node at a time.

<!-- astrona:playground:destroy -->
