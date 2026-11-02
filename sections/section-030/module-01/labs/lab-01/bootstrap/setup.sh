#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-058-lab-030-01-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
node_name="astro-ats-058-lab-030-01-01-control-plane"
worker_name="astro-ats-058-lab-030-01-01-worker"
chart_path="$(mktemp)"
trap 'rm -f "$chart_path"' EXIT
curl --fail --silent --show-error --location --max-time 120 https://helm.cilium.io/cilium-1.20.2.tgz -o "$chart_path"
python3 - "$chart_path" <<'CHECKSUM'
import hashlib,sys
assert hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest() == 'b2afd87b7f75f875f92a14559f14f59b7babbb479d968e3fd625a20bf30ec20e', 'Chart checksum differs'
CHECKSUM
helm upgrade --install cilium "$chart_path" -n kube-system --set ipam.mode=kubernetes --set operator.replicas=1 --set hubble.relay.enabled=true --set bgpControlPlane.enabled=true --wait --timeout 300s
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl wait --for=condition=Ready nodes --all --timeout=180s
kubectl apply -f "$lab_directory/bootstrap/manifests/start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n outpost wait --for=condition=Ready pod/drifter --timeout=120s

