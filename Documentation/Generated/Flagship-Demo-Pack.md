# Flagship Demo Pack

Shareable maintainer pack for the strongest current SwiftIntelligence demo path.

## Current Proof Posture

- publish readiness: `ready`
- distribution posture: `release-grade`
- device classes covered: `Mac, iPhone`
- missing required device classes: `none`
- latest immutable release proof: `v1.2.2`
- repo-native flagship media: `published`

## What To Show First

- demo: [Intelligent Camera](../../Examples/DemoApps/IntelligentCamera/README.md)
- flow: `Vision -> NLP -> Privacy`
- proof command: `bash Scripts/validate-flagship-demo.sh`
- trust surface: [Public Proof Status](Public-Proof-Status.md)
- media status: [Flagship-Media-Status.md](Flagship-Media-Status.md)
- screenshot: [intelligent-camera-success.png](../Assets/Flagship-Demo/intelligent-camera-success.png)
- recording: [intelligent-camera-run.mp4](../Assets/Flagship-Demo/intelligent-camera-run.mp4)
- caption: [caption.txt](../Assets/Flagship-Demo/caption.txt)

## 30-Second Story

SwiftIntelligence is strongest when it connects multiple Apple-native AI frameworks inside one Swift package workflow. Intelligent Camera is the shortest honest proof of that story: Vision extracts signals from a frame, NLP summarizes recognized text, and Privacy tokenizes sensitive output before it is shown.

## Fastest Demo Run Path

1. Add `Core + Vision + NLP + Privacy` to a SwiftUI app target.
2. Replace the default app entry with [IntelligentCameraApp.swift](../../Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift).
3. Run on `macOS 14+` or `iOS 17+`.
4. Tap `Analyze Frame`.

## Success Signals

- `Status` ends with `Vision -> NLP -> Privacy zinciri tamamlandi`
- `Top labels` is populated
- `OCR` is populated
- `Summary` is generated from OCR text
- `Privacy preview` contains tokenized output

## Share Pack Checklist

- published screenshot asset: [intelligent-camera-success.png](../Assets/Flagship-Demo/intelligent-camera-success.png)
- published recording asset: [intelligent-camera-run.mp4](../Assets/Flagship-Demo/intelligent-camera-run.mp4)
- published caption asset: [caption.txt](../Assets/Flagship-Demo/caption.txt)
- one proof link set: [Showcase](../Showcase.md), [Public Proof Status](Public-Proof-Status.md), [Latest Release Proof](Latest-Release-Proof.md)

## Claim Boundaries

- do not present simulator runs as mobile release evidence
- do not claim category leadership from this demo alone
- do not claim best-in-class benchmark performance against external competitors without current comparative proof
