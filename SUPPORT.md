# Support

## Start Here

- Read [README.md](README.md)
- Read [Documentation/README.md](Documentation/README.md)
- Check [Examples/README.md](Examples/README.md)
- For the fastest real demo proof, run [Examples/DemoApps/IntelligentCamera/README.md](Examples/DemoApps/IntelligentCamera/README.md)

## Best Channel by Need

| Need | Best path |
| --- | --- |
| bug report | open a GitHub issue with the bug template |
| feature request | open a GitHub issue with the feature template |
| documentation problem | open a documentation issue |
| performance / benchmark drift | open a performance issue and include validation commands |
| device evidence intake | use the device evidence issue form |
| security issue | use [SECURITY.md](SECURITY.md), not public issues |

## What Makes Support Faster

- exact module name
- exact Swift / Xcode / OS version
- minimal reproduction
- whether `swift build`, `bash Scripts/validate-flagship-demo.sh`, `bash Scripts/validate-examples.sh`, and `swift test` pass locally
- whether `bash Scripts/prepare-release.sh` still passes if the change touches proof, release, or benchmark surfaces

## Operational Note

If GitHub-hosted runners are externally blocked, local maintainer validation remains the authoritative path for triage:

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
bash Scripts/prepare-release.sh
```

## Scope Note

Support is focused on the active modular package graph. Historical umbrella APIs and inactive products may remain in repository history or docs context, but they are not primary support targets.

## Conduct

All project interactions are governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
