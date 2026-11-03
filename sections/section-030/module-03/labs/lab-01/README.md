# Lab: Turn On eBPF Masquerading

Status: UNTESTED. This lab was built with static checks only (`astrona validate`, `bash -n`). It has not been run against a live cluster, so the grading scripts and the reference solution still need a real run.

## Files

- `config.yaml`: lab definition (cluster, bootstrap, validation, teardown).
- `bootstrap/01-setup.sh`: installs Cilium from a checksum-verified chart and applies the manifests.
- `manifests/`: the example application and the starting state.
- `validation/`: one grading script per check.
- `solution/apply.sh`: reference solution, run only by `astrona test`.
- `question.md`, `solution.md`, `prerequisites.md`: learner documents.

## Checks

- `replacement-enabled`, `bpf-masquerade-configured`, `agents-report-bpf-masquerade`, `service-reachable`, `evidence-correct`.

## Open items

- Run `astrona test` against a real cluster and record the result.
- Confirm that `bpf.masquerade=true` works in this release with the settings above, and confirm the format of the `Masquerading` status line that the grading script parses.
