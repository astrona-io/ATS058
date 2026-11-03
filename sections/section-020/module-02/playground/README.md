# Playground: Section 020 module 02

Status: UNTESTED. Built with static checks only (`astrona validate`, `bash -n`). It has not been started against a live environment.

A private ungraded two-node `kind` cluster with Cilium and the example application (`probe`, `shuttle`, `drifter`).

- `config.yaml`: environment definition.
- `bootstrap/01-setup.sh`: installs Cilium from a checksum-verified chart and applies the manifests.
- `manifests/starfleet.yaml`: the example application.
- `docs/overview.md`: guide shown to the learner.
