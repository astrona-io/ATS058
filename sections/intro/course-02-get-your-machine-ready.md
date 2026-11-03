# Get Your Machine Ready

The playgrounds and labs run Kubernetes in containers on your own machine. You need these tools installed: the `astrona` command line tool, `kubectl`, `kind`, a container runtime that `kind` supports such as Docker or Podman, Helm and a shell with `curl`. Cilium needs a recent Linux kernel on the host or inside the virtual machine that runs the containers, because the eBPF features depend on the kernel version. Leave enough memory free for a two-node cluster.

## Commands you use every day

You start a playground from the reading page, and you can also start one from a terminal in the module directory with `astrona run`. A graded lab runs in its own environment. You work in that environment, then check your result with `astrona submit`. Before you run any `kubectl` command, check which cluster it talks to with `kubectl config current-context`. A command that runs against the wrong cluster changes the wrong thing.

The playground and the lab do not share state. Anything you create in one is not present in the other. A lab asks for a specific end state, so read its task carefully before you change the cluster.

## When a start goes wrong

If a playground does not start, check that the container runtime is running and that you have free memory and disk space. If the Cilium pods stay in a state other than `Running`, read their logs with `kubectl -n kube-system logs` and the pod name. Remove a failed environment and start a new one instead of repairing it by hand. The fixtures need no cloud account and write nothing outside your machine.
