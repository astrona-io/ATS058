# Capstone: Add Services And Prove The Flow With Hubble

Status: UNTESTED. This lab was built with static checks only (`astrona validate`, `bash -n`). It has not been run against a live cluster, so the grading scripts and the reference solution still need a real run.

## Files

- `config.yaml`: lab definition (cluster, bootstrap, validation, teardown).
- `bootstrap/01-setup.sh`: installs Cilium from a checksum-verified chart and applies the manifests.
- `manifests/`: the example application and the starting state.
- `validation/`: one grading script per check.
- `solution/apply.sh`: reference solution, run only by `astrona test`.
- `question.md`, `solution.md`, `prerequisites.md`: learner documents.

## Checks

- `hubble-running`, `bench-services-created`, `bench-services-in-map`, `flow-to-new-service-observed`, `capstone-evidence-correct`.

The exact output format of `hubble observe` inside the agent container is not verified (open item).

## Open items

- Run `astrona test` against a real cluster and record the result.
- Confirm command output formats that the grading scripts parse (marked in the scripts).
