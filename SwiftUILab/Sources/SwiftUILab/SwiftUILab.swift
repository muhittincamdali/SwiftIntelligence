import SwiftUI

/// SwiftUILab - A comprehensive collection of 120+ production-ready SwiftUI components
/// Organized into 12 categories for easy discovery and integration
@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct SwiftUILab {
    public static let version = "1.0.0"
    public static let componentCount = 120
    
    public init() {}
    
    /// Component categories available in SwiftUILab
    public enum Category: String, CaseIterable {
        case buttons = "Buttons & Actions"
        case inputs = "Input Controls"
        case cards = "Cards & Containers"
        case charts = "Charts & Graphs"
        case navigation = "Navigation"
        case animations = "Animations"
        case layouts = "Layouts"
        case forms = "Forms"
        case modals = "Modals & Sheets"
        case lists = "Lists & Collections"
        case media = "Media"
        case effects = "Visual Effects"
        
        public var componentCount: Int {
            return 10 // Each category has 10 components
        }
        
        public var icon: String {
            switch self {
            case .buttons: return "button.programmable"
            case .inputs: return "textformat"
            case .cards: return "rectangle.stack"
            case .charts: return "chart.bar"
            case .navigation: return "sidebar.left"
            case .animations: return "wand.and.rays"
            case .layouts: return "square.grid.3x3"
            case .forms: return "doc.text"
            case .modals: return "rectangle.bottomthird.inset.filled"
            case .lists: return "list.bullet"
            case .media: return "photo.on.rectangle"
            case .effects: return "sparkles"
            }
        }
    }
    
    /// Component theme configuration
    public struct Theme {
        public var primaryColor: Color = .blue
        public var secondaryColor: Color = .gray
        public var accentColor: Color = .orange
        public var cornerRadius: CGFloat = 12
        public var spacing: CGFloat = 16
        public var animationDuration: Double = 0.3
        
        public init() {}
        
        public static let `default` = Theme()
        public static let modern = Theme(
            primaryColor: .indigo,
            secondaryColor: .gray,
            accentColor: .purple,
            cornerRadius: 16,
            spacing: 20,
            animationDuration: 0.35
        )
        public static let minimal = Theme(
            primaryColor: .black,
            secondaryColor: .gray,
            accentColor: .blue,
            cornerRadius: 8,
            spacing: 12,
            animationDuration: 0.25
        )
        
        public init(
            primaryColor: Color = .blue,
            secondaryColor: Color = .gray,
            accentColor: Color = .orange,
            cornerRadius: CGFloat = 12,
            spacing: CGFloat = 16,
            animationDuration: Double = 0.3
        ) {
            self.primaryColor = primaryColor
            self.secondaryColor = secondaryColor
            self.accentColor = accentColor
            self.cornerRadius = cornerRadius
            self.spacing = spacing
            self.animationDuration = animationDuration
        }
    }
}

// MARK: - Environment Key

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
struct SwiftUILabThemeKey: EnvironmentKey {
    static let defaultValue = SwiftUILab.Theme.default
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
extension EnvironmentValues {
    public var swiftUILabTheme: SwiftUILab.Theme {
        get { self[SwiftUILabThemeKey.self] }
        set { self[SwiftUILabThemeKey.self] = newValue }
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public extension View {
    func swiftUILabTheme(_ theme: SwiftUILab.Theme) -> some View {
        environment(\.swiftUILabTheme, theme)
    }
}