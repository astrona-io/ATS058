#!/usr/bin/env bash
# Environment only. Installs Cilium from a checksum-verified chart on a kind
# cluster that has no CNI plugin, then creates the example application.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHART="$(mktemp)"
trap 'rm -f "$CHART"' EXIT

curl --fail --silent --show-error --location --max-time 120 https://helm.cilium.io/cilium-1.20.2.tgz -o "$CHART"
python3 - "$CHART" <<'CHECKSUM'
import hashlib, sys
digest = hashlib.sha256(open(sys.argv[1], 'rb').read()).hexdigest()
assert digest == 'b2afd87b7f75f875f92a14559f14f59b7babbb479d968e3fd625a20bf30ec20e', 'Cilium chart checksum differs'
CHECKSUM

helm upgrade --install cilium "$CHART" --namespace kube-system \
  --set ipam.mode=kubernetes --set operator.replicas=1 --set hubble.enabled=true --set hubble.relay.enabled=true \
  --wait --timeout 300s
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl -n kube-system rollout status deployment/hubble-relay --timeout=300s
kubectl wait --for=condition=Ready nodes --all --timeout=180s

kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl apply -f "$DIR/manifests/ats058-020-03-extra.yaml"
for name in probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
