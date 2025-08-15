import SwiftUI

// MARK: - Primary Button Style

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.swiftUILabTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(isEnabled ? theme.primaryColor : Color.gray)
                    .shadow(
                        color: configuration.isPressed ? .clear : theme.primaryColor.opacity(0.3),
                        radius: configuration.isPressed ? 0 : 8,
                        y: configuration.isPressed ? 0 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.swiftUILabTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? theme.primaryColor : .gray)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(isEnabled ? theme.primaryColor : Color.gray, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Ghost Button Style

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct GhostButtonStyle: ButtonStyle {
    @Environment(\.swiftUILabTheme) private var theme
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(theme.primaryColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                configuration.isPressed
                    ? theme.primaryColor.opacity(0.1)
                    : Color.clear
            )
            .cornerRadius(theme.cornerRadius)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Destructive Button Style

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.swiftUILabTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(isEnabled ? Color.red : Color.gray)
                    .shadow(
                        color: configuration.isPressed ? .clear : Color.red.opacity(0.3),
                        radius: configuration.isPressed ? 0 : 8,
                        y: configuration.isPressed ? 0 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Gradient Button Style

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct GradientButtonStyle: ButtonStyle {
    @Environment(\.swiftUILabTheme) private var theme
    let colors: [Color]
    
    public init(colors: [Color]? = nil) {
        self.colors = colors ?? []
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let gradient = LinearGradient(
            colors: colors.isEmpty ? [theme.primaryColor, theme.accentColor] : colors,
            startPoint: .leading,
            endPoint: .trailing
        )
        
        return configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(gradient)
                    .shadow(
                        color: configuration.isPressed ? .clear : theme.primaryColor.opacity(0.3),
                        radius: configuration.isPressed ? 0 : 8,
                        y: configuration.isPressed ? 0 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Neumorphic Button Style

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct NeumorphicButtonStyle: ButtonStyle {
    @Environment(\.swiftUILabTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        let isLight = colorScheme == .light
        let bgColor = isLight ? Color(white: 0.95) : Color(white: 0.15)
        let lightShadow = isLight ? Color.white : Color(white: 0.25)
        let darkShadow = isLight ? Color.black.opacity(0.2) : Color.black.opacity(0.8)
        
        return configuration.label
            .foregroundColor(theme.primaryColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(bgColor)
                    .shadow(
                        color: configuration.isPressed ? darkShadow : lightShadow,
                        radius: configuration.isPressed ? 2 : 6,
                        x: configuration.isPressed ? 2 : -4,
                        y: configuration.isPressed ? 2 : -4
                    )
                    .shadow(
                        color: configuration.isPressed ? lightShadow : darkShadow,
                        radius: configuration.isPressed ? 2 : 6,
                        x: configuration.isPressed ? -2 : 4,
                        y: configuration.isPressed ? -2 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Extension for Easy Access

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public extension ButtonStyle where Self == GhostButtonStyle {
    static var ghost: GhostButtonStyle { GhostButtonStyle() }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public extension ButtonStyle where Self == DestructiveButtonStyle {
    static var destructive: DestructiveButtonStyle { DestructiveButtonStyle() }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public extension ButtonStyle where Self == NeumorphicButtonStyle {
    static var neumorphic: NeumorphicButtonStyle { NeumorphicButtonStyle() }
}