# SwiftIntelligence Diagrams

These diagrams describe the active modular package graph.

## Files

- `architecture.mermaid`: current runtime layers
- `module-dependencies.mermaid`: active package dependencies
- `data-flow.mermaid`: request flow through the modular stack
- `class-hierarchy.mermaid`: main public entry points
- `deployment.mermaid`: current distribution and CI shape

## Ground Rules

- diagrams must reflect the active package graph
- inactive umbrella or legacy products should not appear as active nodes
- benchmark, CI, and release flows should match the current repo state

## Rendering

GitHub can render Mermaid in markdown contexts. For local exports:

```bash
npm install -g @mermaid-js/mermaid-cli
mmdc -i architecture.mermaid -o architecture.svg
```
