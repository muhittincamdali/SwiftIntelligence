import SwiftUI

/// SwiftUILabButtons - Main export module for all button components
@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct SwiftUILabButtons {
    public init() {}
    
    /// Available button components in this module
    public enum Component: String, CaseIterable {
        case primaryButton = "Primary Button"
        case secondaryButton = "Secondary Button"
        case loadingButton = "Loading Button"
        case progressButton = "Progress Button"
        case floatingActionButton = "Floating Action Button"
        case expandableFAB = "Expandable FAB"
        case socialButton = "Social Button"
        case toggleButton = "Toggle Button"
        case segmentedToggle = "Segmented Toggle"
        case checkboxButton = "Checkbox Button"
        
        public var description: String {
            switch self {
            case .primaryButton:
                return "Primary action button with prominent styling"
            case .secondaryButton:
                return "Secondary action button with outlined style"
            case .loadingButton:
                return "Button with loading state indicator"
            case .progressButton:
                return "Button showing operation progress"
            case .floatingActionButton:
                return "Material Design floating action button"
            case .expandableFAB:
                return "FAB with expandable menu items"
            case .socialButton:
                return "Social media login/share buttons"
            case .toggleButton:
                return "Toggle button with on/off states"
            case .segmentedToggle:
                return "Segmented control for multiple options"
            case .checkboxButton:
                return "Checkbox with label for selections"
            }
        }
    }
}

// MARK: - Button Demo View

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct ButtonsDemoView: View {
    @State private var isToggled = false
    @State private var selectedSegment = 0
    @State private var isChecked = false
    @State private var selectedRadio: Int? = 1
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Button Styles Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Button Styles")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        Button("Primary") {}
                            .buttonStyle(.primary)
                        
                        Button("Secondary") {}
                            .buttonStyle(.secondary)
                        
                        Button("Ghost") {}
                            .buttonStyle(.ghost)
                    }
                    
                    HStack(spacing: 16) {
                        Button("Destructive") {}
                            .buttonStyle(.destructive)
                        
                        Button("Gradient") {}
                            .buttonStyle(GradientButtonStyle())
                        
                        Button("Neumorphic") {}
                            .buttonStyle(.neumorphic)
                    }
                }
                
                Divider()
                
                // Loading Buttons Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Loading Buttons")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    LoadingButton("Load Data") {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                    }
                    .buttonStyle(.primary)
                    
                    ProgressButton { progress in
                        for i in 0...100 {
                            progress.completedUnitCount = Int64(i)
                            try? await Task.sleep(nanoseconds: 20_000_000)
                        }
                    } label: {
                        Text("Upload File")
                    }
                    
                    AnimatedSubmitButton("Submit") {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        return Bool.random()
                    }
                }
                
                Divider()
                
                // Toggle Buttons Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Toggle & Selection")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ToggleButton(
                        isOn: $isToggled,
                        onIcon: "checkmark",
                        offIcon: "xmark",
                        onLabel: "Enabled",
                        offLabel: "Disabled"
                    )
                    
                    SegmentedToggle(
                        selection: $selectedSegment,
                        options: [
                            (0, "Day"),
                            (1, "Week"),
                            (2, "Month"),
                            (3, "Year")
                        ]
                    )
                    
                    CheckboxButton(
                        isChecked: $isChecked,
                        label: "I agree to the terms",
                        style: .square
                    )
                    
                    RadioButtonGroup(
                        selection: $selectedRadio,
                        options: [
                            (1, "Option 1"),
                            (2, "Option 2"),
                            (3, "Option 3")
                        ]
                    )
                }
                
                Divider()
                
                // Social Buttons Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Social Buttons")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    SocialButtonGroup(
                        platforms: [.apple, .google, .facebook, .github],
                        style: .iconOnly,
                        axis: .horizontal
                    ) { platform in
                        print("Tapped \(platform.rawValue)")
                    }
                    
                    VStack(spacing: 12) {
                        SocialButton(platform: .apple, style: .filled) {
                            print("Apple login")
                        }
                        
                        SocialButton(platform: .google, style: .outlined) {
                            print("Google login")
                        }
                        
                        AnimatedSocialButton(platform: .github) {
                            print("GitHub login")
                        }
                    }
                }
                
                Divider()
                
                // Floating Action Buttons
                VStack(alignment: .leading, spacing: 20) {
                    Text("Floating Action Buttons")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 30) {
                        FloatingActionButton(icon: "plus") {
                            print("FAB tapped")
                        }
                        
                        FloatingActionButton(icon: "camera", size: 48) {
                            print("Camera FAB tapped")
                        }
                        
                        FloatingActionButton(icon: "pencil", size: 40) {
                            print("Edit FAB tapped")
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Button Components")
    }
}