# Prerequisites

Before you start, make sure these tools are installed and working on your machine:

- `astrona`, the command line tool that starts the lab and grades it.
- `docker`, because the lab cluster runs as containers.
- `kubectl`, the Kubernetes command line client. It already points at the lab cluster after the lab starts.
- `helm`, the Kubernetes package manager, which the setup script uses to install Cilium.

You need basic Kubernetes knowledge: pods, Services, namespaces and `kubectl`.

You also need network access to the Cilium Helm repository, because the solution upgrades the Cilium release.

The lab starts a two-node `kind` cluster without a default network plugin, installs Cilium and creates the example application. The first start takes several minutes because the images must be pulled.
