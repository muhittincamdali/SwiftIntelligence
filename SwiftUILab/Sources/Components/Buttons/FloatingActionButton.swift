import SwiftUI

// MARK: - Floating Action Button

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct FloatingActionButton: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    let icon: String
    let action: () -> Void
    let size: CGFloat
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    public init(
        icon: String = "plus",
        size: CGFloat = 56,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(theme.primaryColor)
                        .shadow(
                            color: theme.primaryColor.opacity(0.3),
                            radius: isPressed ? 4 : 12,
                            y: isPressed ? 2 : 6
                        )
                )
                .scaleEffect(isPressed ? 0.9 : (isHovered ? 1.05 : 1.0))
                .rotationEffect(.degrees(isPressed ? 90 : 0))
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovered = hovering
            }
        }
        ._onButtonGesture { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }
    }
}

// MARK: - Expandable FAB

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct ExpandableFAB: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    let primaryIcon: String
    let items: [FABItem]
    let size: CGFloat
    
    @State private var isExpanded = false
    @State private var animateItems = false
    
    public struct FABItem: Identifiable {
        public let id = UUID()
        public let icon: String
        public let label: String
        public let color: Color
        public let action: () -> Void
        
        public init(
            icon: String,
            label: String,
            color: Color = .blue,
            action: @escaping () -> Void
        ) {
            self.icon = icon
            self.label = label
            self.color = color
            self.action = action
        }
    }
    
    public init(
        icon: String = "plus",
        items: [FABItem],
        size: CGFloat = 56
    ) {
        self.primaryIcon = icon
        self.items = items
        self.size = size
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Overlay to close FAB when expanded
            if isExpanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        toggleExpansion()
                    }
                    .transition(.opacity)
            }
            
            // Secondary buttons
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HStack {
                    if isExpanded {
                        Text(item.label)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 2)
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button(action: {
                        item.action()
                        toggleExpansion()
                    }) {
                        Image(systemName: item.icon)
                            .font(.system(size: size * 0.35, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: size * 0.8, height: size * 0.8)
                            .background(
                                Circle()
                                    .fill(item.color)
                                    .shadow(radius: 4)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .offset(
                    x: 0,
                    y: isExpanded ? -CGFloat(index + 1) * (size + 16) : 0
                )
                .opacity(animateItems ? 1 : 0)
                .scaleEffect(animateItems ? 1 : 0.5)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.7)
                        .delay(isExpanded ? Double(index) * 0.05 : 0),
                    value: animateItems
                )
            }
            
            // Primary button
            Button(action: toggleExpansion) {
                Image(systemName: primaryIcon)
                    .font(.system(size: size * 0.4, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
                    .frame(width: size, height: size)
                    .background(
                        Circle()
                            .fill(theme.primaryColor)
                            .shadow(
                                color: theme.primaryColor.opacity(0.3),
                                radius: 12,
                                y: 6
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isExpanded)
    }
    
    private func toggleExpansion() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isExpanded.toggle()
        }
        
        if isExpanded {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1)) {
                animateItems = true
            }
        } else {
            animateItems = false
        }
    }
}

// MARK: - Button Gesture Modifier

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
struct ButtonGestureModifier: ViewModifier {
    let action: (Bool) -> Void
    @GestureState private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
                    .onChanged { _ in
                        action(true)
                    }
                    .onEnded { _ in
                        action(false)
                    }
            )
            .onChange(of: isPressed) { _, newValue in
                action(newValue)
            }
    }
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
extension View {
    func _onButtonGesture(perform action: @escaping (Bool) -> Void) -> some View {
        modifier(ButtonGestureModifier(action: action))
    }
}