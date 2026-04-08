# Pull Request

## Summary

<!-- What changed and why? Keep it concrete. -->

## Change Type

- [ ] Bug fix
- [ ] Feature
- [ ] Refactor
- [ ] Documentation
- [ ] Build / CI
- [ ] Performance
- [ ] Security
- [ ] Breaking change

## Affected Areas

- [ ] Core
- [ ] ML
- [ ] NLP
- [ ] Vision
- [ ] Speech
- [ ] Privacy
- [ ] Reasoning
- [ ] Network / Cache / Metrics
- [ ] Benchmarks
- [ ] Examples
- [ ] Documentation
- [ ] GitHub workflows

## Validation

- [ ] `swift build`
- [ ] `bash Scripts/validate-examples.sh`
- [ ] `bash Scripts/validate-flagship-demo.sh` if flagship demo, onboarding, or comparison surfaces changed
- [ ] `swift test`
- [ ] `bash Scripts/run-benchmarks.sh smoke Benchmarks/Results/ci-smoke` if performance-sensitive code changed
- [ ] `bash Scripts/run-benchmarks.sh standard Benchmarks/Results/latest` if release or public performance claims changed
- [ ] `bash Scripts/validate-device-evidence.sh` if benchmark/device evidence changed
- [ ] `bash Scripts/validate-transfer-chain.sh` if benchmark export/import flow changed
- [ ] `bash Scripts/validate-release-provenance.sh` if release metadata/provenance flow changed
- [ ] `bash Scripts/import-benchmark-evidence.sh ...` or `bash Scripts/run-benchmarks-for-device.sh ...` details documented below if a non-Mac device bundle was added

## Security / Privacy

- [ ] No secrets, tokens, or credentials were added
- [ ] External inputs remain validated at system boundaries
- [ ] Privacy-sensitive flows were reviewed if data transport changed

## Documentation

- [ ] README / docs updated if public behavior changed
- [ ] Examples updated if API usage changed
- [ ] Changelog updated if the change is maintainer-visible
- [ ] Device evidence docs updated if benchmark coverage or release proof changed

## Product Impact

- First-user path affected:
- Best first module affected:
- Who should use this changed:
- Who should not use this changed:

## Public Claim Impact

- [ ] No public claim changed
- [ ] Public proof, benchmark, or readiness wording changed and matching docs/generated surfaces were updated
- [ ] Release-grade claim surface was reviewed for drift

## Device Evidence Details

<!-- If benchmark/device evidence changed, record snapshot name, device class, and whether capture/import was used. -->

## Review Focus

<!-- Call out the highest-risk area for reviewers. -->

## Related Issues

<!-- Example: Fixes #123 -->
