# Device Evidence Handoff

Generated export surface for the missing device evidence waves that still block release-grade benchmark positioning.

## Status

- Publish readiness: `ready`
- Distribution posture: `release-grade`
- Pending device classes: `none`
- Queue source: [Device-Evidence-Queue.md](Device-Evidence-Queue.md)
- Intake source: [Device-Evidence-Intake.md](Device-Evidence-Intake.md)
- Runbook source: [Device-Evidence-Runbook.md](Device-Evidence-Runbook.md)
- Machine-readable payload: [device-evidence-handoff.json](device-evidence-handoff.json)

## Export Command

```bash
bash Scripts/export-device-evidence-handoff.sh /absolute/path/to/device-evidence-handoff.tar.gz
```

## Included Surfaces

- queue summary and JSON payload
- intake summary and maintainer runbook
- packet index and per-device packet folders
- release blockers and public proof envelope
- GitHub `device_evidence` issue form

## State

- No pending device evidence waves remain.
