# Welcome To The Course

This course covers the eBPF domain of the Cilium Certified Associate (CCA) exam. The domain is worth 10% of the exam. The material is written by independent authors and is not an official exam simulation. The exam itself is multiple choice.

eBPF is a Linux kernel technology that runs small, verified programs inside the kernel. Cilium is a Kubernetes networking, security and observability project that loads such programs on every node. After this course you can explain how an eBPF program is loaded and what the verifier checks. You can name the hooks and maps that Cilium uses. You can describe what the eBPF datapath gains over the iptables rules that kube-proxy writes. You can also replace kube-proxy with Cilium on a test cluster.

## Words the course uses

A hook is a place in the kernel where a program runs. A map is a table in kernel memory that programs and user space processes share. The Cilium agent is the pod on each node that writes those maps. A datapath is the path that a packet takes through the node. The course explains each term again where it first matters.

## The example application

Every example uses the same small application. The `shuttle` pod in the `starfleet` namespace sends requests to the `probe` Service in the same namespace. The `drifter` pod in the `outpost` namespace is a second client. The names only make the examples easy to follow. They have no technical meaning.

## How the course is laid out

The course has three sections, one for each official objective. A section has two modules, a capstone lab and a knowledge check. A module has a landing page, two reading parts and a summary. Each module also has a playground, which is a private cluster where you try the commands, and a graded lab, which checks the state of a cluster that you change.

## How to read a page

Read the parts in order. Run the commands in the playground when a part asks you to. Read the output of your own cluster and do not expect it to match another machine, because kernel versions and Cilium releases differ. Attempt each lab before you open its solution. All runtime behavior in this course is written from the documentation and has not yet been run, so report anything that does not match what you see.
