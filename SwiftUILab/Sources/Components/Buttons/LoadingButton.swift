import SwiftUI

// MARK: - Loading Button

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct LoadingButton<Label: View>: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    let action: () async -> Void
    let label: Label
    @State private var isLoading = false
    
    public init(
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button {
            Task {
                isLoading = true
                await action()
                isLoading = false
            }
        } label: {
            ZStack {
                label
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                }
            }
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: theme.animationDuration), value: isLoading)
    }
}

// MARK: - Convenience Initializer

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public extension LoadingButton where Label == Text {
    init(
        _ title: String,
        action: @escaping () async -> Void
    ) {
        self.init(action: action) {
            Text(title)
        }
    }
}

// MARK: - Loading Button with Progress

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct ProgressButton<Label: View>: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    let action: (Progress) async -> Void
    let label: Label
    @State private var isLoading = false
    @State private var progress: Double = 0
    
    public init(
        action: @escaping (Progress) async -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button {
            Task {
                isLoading = true
                progress = 0
                
                let progressTracker = Progress(totalUnitCount: 100)
                
                // Create a task to monitor progress
                Task {
                    for await _ in Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().values {
                        if !isLoading { break }
                        withAnimation(.linear(duration: 0.1)) {
                            progress = progressTracker.fractionCompleted
                        }
                    }
                }
                
                await action(progressTracker)
                
                withAnimation {
                    progress = 1.0
                }
                
                try? await Task.sleep(nanoseconds: 300_000_000)
                
                isLoading = false
                progress = 0
            }
        } label: {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .fill(theme.primaryColor.opacity(0.2))
                    
                    // Progress fill
                    if isLoading {
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .fill(theme.primaryColor)
                            .frame(width: geometry.size.width * progress)
                            .animation(.linear(duration: 0.1), value: progress)
                    }
                    
                    // Label
                    HStack {
                        Spacer()
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.7)
                                Text("\(Int(progress * 100))%")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        } else {
                            label
                        }
                        Spacer()
                    }
                    .foregroundColor(isLoading ? .white : theme.primaryColor)
                }
            }
            .frame(height: 44)
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: theme.animationDuration), value: isLoading)
    }
}

// MARK: - Animated Submit Button

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct AnimatedSubmitButton: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    let title: String
    let action: () async -> Bool
    
    @State private var state: ButtonState = .idle
    @State private var animate = false
    
    enum ButtonState {
        case idle
        case loading
        case success
        case failure
    }
    
    public init(
        _ title: String,
        action: @escaping () async -> Bool
    ) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button {
            Task {
                state = .loading
                let success = await action()
                withAnimation(.spring()) {
                    state = success ? .success : .failure
                }
                
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                withAnimation {
                    state = .idle
                }
            }
        } label: {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Capsule()
                        .fill(backgroundColorForState)
                        .frame(
                            width: widthForState(geometry.size.width),
                            height: 50
                        )
                    
                    // Content
                    Group {
                        switch state {
                        case .idle:
                            Text(title)
                                .fontWeight(.semibold)
                        case .loading:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        case .success:
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .fontWeight(.bold)
                        case .failure:
                            Image(systemName: "xmark")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                }
                .frame(width: geometry.size.width, height: 50)
            }
            .frame(height: 50)
        }
        .disabled(state != .idle)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: state)
    }
    
    private var backgroundColorForState: Color {
        switch state {
        case .idle:
            return theme.primaryColor
        case .loading:
            return theme.primaryColor.opacity(0.8)
        case .success:
            return .green
        case .failure:
            return .red
        }
    }
    
    private func widthForState(_ maxWidth: CGFloat) -> CGFloat {
        switch state {
        case .idle:
            return maxWidth
        case .loading, .success, .failure:
            return 50
        }
    }
}