import SwiftUI

// MARK: - Toggle Button

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct ToggleButton: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    @Binding var isOn: Bool
    let onIcon: String
    let offIcon: String
    let onLabel: String?
    let offLabel: String?
    
    public init(
        isOn: Binding<Bool>,
        onIcon: String = "checkmark",
        offIcon: String = "xmark",
        onLabel: String? = nil,
        offLabel: String? = nil
    ) {
        self._isOn = isOn
        self.onIcon = onIcon
        self.offIcon = offIcon
        self.onLabel = onLabel
        self.offLabel = offLabel
    }
    
    public var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isOn ? onIcon : offIcon)
                    .font(.system(size: 16, weight: .medium))
                    .rotationEffect(.degrees(isOn ? 0 : 180))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isOn)
                
                if let label = isOn ? onLabel : offLabel {
                    Text(label)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(isOn ? .white : theme.primaryColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(isOn ? theme.primaryColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .stroke(theme.primaryColor, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Segmented Toggle

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct SegmentedToggle<Value: Hashable>: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    @Binding var selection: Value
    let options: [(Value, String)]
    
    @Namespace private var namespace
    
    public init(
        selection: Binding<Value>,
        options: [(Value, String)]
    ) {
        self._selection = selection
        self.options = options
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.0) { value, label in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = value
                    }
                } label: {
                    Text(label)
                        .fontWeight(.medium)
                        .foregroundColor(selection == value ? .white : theme.primaryColor)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Group {
                                if selection == value {
                                    RoundedRectangle(cornerRadius: theme.cornerRadius - 2)
                                        .fill(theme.primaryColor)
                                        .matchedGeometryEffect(id: "selection", in: namespace)
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(theme.primaryColor, lineWidth: 2)
        )
    }
}

// MARK: - Checkbox Button

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct CheckboxButton: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    @Binding var isChecked: Bool
    let label: String
    let style: CheckboxStyle
    
    public enum CheckboxStyle {
        case square
        case circle
        case custom(String, String)
    }
    
    public init(
        isChecked: Binding<Bool>,
        label: String,
        style: CheckboxStyle = .square
    ) {
        self._isChecked = isChecked
        self.label = label
        self.style = style
    }
    
    public var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isChecked.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    shape
                        .stroke(isChecked ? theme.primaryColor : Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    shape
                        .fill(isChecked ? theme.primaryColor : Color.clear)
                        .frame(width: 24, height: 24)
                    
                    if isChecked {
                        Image(systemName: checkmarkIcon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                Text(label)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var shape: some Shape {
        switch style {
        case .square:
            RoundedRectangle(cornerRadius: 4)
        case .circle:
            Circle()
        case .custom:
            RoundedRectangle(cornerRadius: 4)
        }
    }
    
    private var checkmarkIcon: String {
        switch style {
        case .square, .circle:
            return "checkmark"
        case .custom(let unchecked, let checked):
            return isChecked ? checked : unchecked
        }
    }
}

// MARK: - Radio Button Group

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct RadioButtonGroup<Value: Hashable>: View {
    @Environment(\.swiftUILabTheme) private var theme
    
    @Binding var selection: Value?
    let options: [(Value, String)]
    let axis: Axis
    
    public init(
        selection: Binding<Value?>,
        options: [(Value, String)],
        axis: Axis = .vertical
    ) {
        self._selection = selection
        self.options = options
        self.axis = axis
    }
    
    public var body: some View {
        Group {
            if axis == .vertical {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(options, id: \.0) { value, label in
                        radioButton(value: value, label: label)
                    }
                }
            } else {
                HStack(spacing: 20) {
                    ForEach(options, id: \.0) { value, label in
                        radioButton(value: value, label: label)
                    }
                }
            }
        }
    }
    
    private func radioButton(value: Value, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selection = value
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(selection == value ? theme.primaryColor : Color.gray, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if selection == value {
                        Circle()
                            .fill(theme.primaryColor)
                            .frame(width: 10, height: 10)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                Text(label)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}