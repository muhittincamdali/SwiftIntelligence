import SwiftUI

// MARK: - Social Button

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct SocialButton: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    let platform: SocialPlatform
    let style: ButtonVariant
    let action: () -> Void
    
    public enum SocialPlatform: String, CaseIterable {
        case apple = "Apple"
        case google = "Google"
        case facebook = "Facebook"
        case twitter = "Twitter"
        case github = "GitHub"
        case linkedin = "LinkedIn"
        case microsoft = "Microsoft"
        
        var icon: String {
            switch self {
            case .apple: return "apple.logo"
            case .google: return "g.circle.fill"
            case .facebook: return "f.circle.fill"
            case .twitter: return "x.circle.fill"
            case .github: return "chevron.left.forwardslash.chevron.right"
            case .linkedin: return "l.circle.fill"
            case .microsoft: return "microsoft.logo"
            }
        }
        
        var color: Color {
            switch self {
            case .apple: return .black
            case .google: return Color(red: 0.25, green: 0.52, blue: 0.96)
            case .facebook: return Color(red: 0.26, green: 0.40, blue: 0.70)
            case .twitter: return .black
            case .github: return .black
            case .linkedin: return Color(red: 0.0, green: 0.46, blue: 0.71)
            case .microsoft: return Color(red: 0.0, green: 0.53, blue: 0.82)
            }
        }
    }
    
    public enum ButtonVariant {
        case filled
        case outlined
        case iconOnly
        case withText(String)
    }
    
    public init(
        platform: SocialPlatform,
        style: ButtonVariant = .filled,
        action: @escaping () -> Void
    ) {
        self.platform = platform
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            switch style {
            case .filled:
                filledButton
            case .outlined:
                outlinedButton
            case .iconOnly:
                iconOnlyButton
            case .withText(let text):
                textButton(text)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var filledButton: some View {
        HStack(spacing: 8) {
            Image(systemName: platform.icon)
                .font(.system(size: 18, weight: .medium))
            Text("Continue with \(platform.rawValue)")
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(platform.color)
        )
    }
    
    private var outlinedButton: some View {
        HStack(spacing: 8) {
            Image(systemName: platform.icon)
                .font(.system(size: 18, weight: .medium))
            Text("Continue with \(platform.rawValue)")
                .fontWeight(.medium)
        }
        .foregroundColor(platform.color)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(platform.color, lineWidth: 2)
        )
    }
    
    private var iconOnlyButton: some View {
        Image(systemName: platform.icon)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(platform.color)
            )
    }
    
    private func textButton(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: platform.icon)
                .font(.system(size: 18, weight: .medium))
            Text(text)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(platform.color)
        )
    }
}

// MARK: - Social Button Group

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct SocialButtonGroup: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    let platforms: [SocialButton.SocialPlatform]
    let style: SocialButton.ButtonVariant
    let axis: Axis
    let action: (SocialButton.SocialPlatform) -> Void
    
    public init(
        platforms: [SocialButton.SocialPlatform],
        style: SocialButton.ButtonVariant = .iconOnly,
        axis: Axis = .horizontal,
        action: @escaping (SocialButton.SocialPlatform) -> Void
    ) {
        self.platforms = platforms
        self.style = style
        self.axis = axis
        self.action = action
    }
    
    public var body: some View {
        Group {
            if axis == .horizontal {
                HStack(spacing: theme.spacing) {
                    ForEach(platforms, id: \.self) { platform in
                        SocialButton(
                            platform: platform,
                            style: style
                        ) {
                            action(platform)
                        }
                    }
                }
            } else {
                VStack(spacing: theme.spacing) {
                    ForEach(platforms, id: \.self) { platform in
                        SocialButton(
                            platform: platform,
                            style: style
                        ) {
                            action(platform)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Animated Social Button

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct AnimatedSocialButton: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    let platform: SocialButton.SocialPlatform
    let action: () -> Void
    
    @State private var isAnimating = false
    @State private var showCheckmark = false
    
    public init(
        platform: SocialButton.SocialPlatform,
        action: @escaping () -> Void
    ) {
        self.platform = platform
        self.action = action
    }
    
    public var body: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                isAnimating = true
            }
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showCheckmark = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showCheckmark = false
                        isAnimating = false
                    }
                }
            }
        } label: {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(platform.color)
                    .frame(
                        width: isAnimating ? 50 : 200,
                        height: 50
                    )
                
                // Content
                if showCheckmark {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                } else if isAnimating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: platform.icon)
                            .font(.system(size: 18, weight: .medium))
                        Text("Sign in with \(platform.rawValue)")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(height: 50)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isAnimating)
    }
}