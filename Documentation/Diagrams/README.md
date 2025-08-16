# SwiftIntelligence Architecture Diagrams

This directory contains architectural diagrams for the SwiftIntelligence framework.

## 📊 Available Diagrams

### 1. System Architecture (`architecture.mermaid`)
High-level overview of the framework's modular architecture showing:
- Application Layer
- API Layer
- AI/ML Modules
- Core Infrastructure
- Support Modules
- Platform Frameworks

### 2. Data Flow (`data-flow.mermaid`)
Sequence diagram showing:
- Standard AI processing flow
- Error handling flow
- Multi-modal processing
- Cache interactions
- Privacy filters

### 3. Module Dependencies (`module-dependencies.mermaid`)
Dependency graph showing:
- Module relationships
- Layer organization
- Dependency direction
- Core module centrality

### 4. Class Hierarchy (`class-hierarchy.mermaid`)
UML-style class diagram showing:
- Main classes and protocols
- Inheritance relationships
- Protocol conformance
- Key properties and methods

### 5. Deployment Architecture (`deployment.mermaid`)
Deployment diagram showing:
- Platform targets
- Binary distribution
- Framework embedding
- App integration

## 🔧 Viewing Diagrams

### Option 1: GitHub
GitHub automatically renders Mermaid diagrams in markdown files.

### Option 2: Mermaid Live Editor
Visit [Mermaid Live Editor](https://mermaid.live/) and paste the diagram code.

### Option 3: VS Code Extension
Install the "Mermaid Preview" extension in VS Code.

### Option 4: Generate Images
```bash
# Install mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Generate PNG
mmdc -i architecture.mermaid -o architecture.png

# Generate SVG
mmdc -i architecture.mermaid -o architecture.svg
```

## 🎨 Diagram Conventions

### Colors
- 🟢 **Green**: Application/UI Layer
- 🔵 **Blue**: API/Interface Layer
- 🟣 **Purple**: AI/ML Modules
- 🔴 **Red**: Core Infrastructure
- 🟠 **Orange**: Support Modules
- ⚫ **Gray**: Platform Frameworks

### Shapes
- **Rectangles**: Modules/Components
- **Circles**: Entry Points
- **Diamonds**: Decision Points
- **Cylinders**: Data Storage

### Lines
- **Solid**: Direct dependency
- **Dashed**: Optional dependency
- **Thick**: Primary flow
- **Thin**: Secondary flow

## 📝 Updating Diagrams

When updating diagrams:

1. **Keep it Simple**: Focus on clarity over detail
2. **Use Consistent Styling**: Follow color and shape conventions
3. **Document Changes**: Update this README when adding new diagrams
4. **Version Control**: Commit diagram changes with descriptive messages

## 🔄 Diagram Generation Script

Use the provided script to generate all diagrams as images:

```bash
#!/bin/bash
# generate-diagrams.sh

for file in *.mermaid; do
    base="${file%.mermaid}"
    echo "Generating $base.png..."
    mmdc -i "$file" -o "$base.png" -t dark -b transparent
    echo "Generating $base.svg..."
    mmdc -i "$file" -o "$base.svg" -t dark -b transparent
done
```

## 📚 Additional Resources

- [Mermaid Documentation](https://mermaid-js.github.io/mermaid/)
- [Mermaid Cheat Sheet](https://jojozhuang.github.io/tutorial/mermaid-cheat-sheet/)
- [PlantUML Alternative](https://plantuml.com/) for more complex diagrams

## 🤝 Contributing

When contributing new diagrams:

1. Follow existing naming conventions
2. Include the diagram in this README
3. Test rendering on GitHub
4. Ensure diagrams are readable at different sizes

## 📄 License

These diagrams are part of the SwiftIntelligence project and are covered under the same MIT license.