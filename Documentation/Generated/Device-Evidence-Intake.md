# Device Evidence Intake

Generated maintainer intake summary for the device classes still blocking release-grade benchmark readiness.

## Current Gap

- Missing required release device classes: `none`
- Capture packets: [Device-Capture-Packets.md](Device-Capture-Packets.md)
- Runbook: [Device-Evidence-Runbook.md](Device-Evidence-Runbook.md)
- Issue form: [../../.github/ISSUE_TEMPLATE/device_evidence.yml](../../.github/ISSUE_TEMPLATE/device_evidence.yml)

## Intake Steps

1. Pick the matching device packet from `Device-Capture-Packets/<device-class>/`.
2. Run its `capture.sh` on the source machine, or receive the exported archive.
3. Run its `import.sh` in this checkout.
4. Open the `Device Evidence Submission` issue using the packet-local `issue-submission.md` and `issue-fields.json`.
5. Re-run `bash Scripts/prepare-release.sh` and verify generated coverage surfaces moved in the expected direction.

## Missing Device Classes

### none

- Packet README: [Device-Capture-Packets/none/README.md](Device-Capture-Packets/none/README.md)
- Issue fields: [Device-Capture-Packets/none/issue-fields.json](Device-Capture-Packets/none/issue-fields.json)
- Issue submission: [Device-Capture-Packets/none/issue-submission.md](Device-Capture-Packets/none/issue-submission.md)

