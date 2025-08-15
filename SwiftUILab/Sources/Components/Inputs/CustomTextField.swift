import SwiftUI

// MARK: - Custom Text Field

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String?
    let isSecure: Bool
    let validation: ((String) -> Bool)?
    
    @State private var isValid = true
    @State private var isFocused = false
    @FocusState private var textFieldFocused: Bool
    
    public init(
        text: Binding<String>,
        placeholder: String,
        icon: String? = nil,
        isSecure: Bool = false,
        validation: ((String) -> Bool)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.isSecure = isSecure
        self.validation = validation
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .blue : .gray)
                    .frame(width: 20)
            }
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .focused($textFieldFocused)
            .onChange(of: text) { _, newValue in
                if let validation = validation {
                    isValid = validation(newValue)
                }
            }
            
            if !isValid {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 2)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
        )
        .onChange(of: textFieldFocused) { _, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                isFocused = newValue
            }
        }
    }
    
    private var borderColor: Color {
        if !isValid {
            return .red
        } else if isFocused {
            return .blue
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Floating Label TextField

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct FloatingLabelTextField: View {
    @Binding var text: String
    let placeholder: String
    
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    
    public init(text: Binding<String>, placeholder: String) {
        self._text = text
        self.placeholder = placeholder
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            Text(placeholder)
                .foregroundColor(.gray)
                .offset(y: text.isEmpty && !isFocused ? 0 : -25)
                .scaleEffect(text.isEmpty && !isFocused ? 1 : 0.8, anchor: .leading)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: text.isEmpty)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
            
            TextField("", text: $text)
                .focused($isFocused)
                .padding(.top, text.isEmpty && !isFocused ? 0 : 15)
        }
        .padding(.vertical, 10)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(isFocused ? .blue : .gray.opacity(0.3))
                .padding(.top, 35),
            alignment: .bottom
        )
    }
}

// MARK: - Search Bar

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct CustomSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: ((String) -> Void)?
    
    @State private var isSearching = false
    @FocusState private var isFocused: Bool
    
    public init(
        text: Binding<String>,
        placeholder: String = "Search...",
        onSearch: ((String) -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearch = onSearch
    }
    
    public var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .onSubmit {
                        onSearch?(text)
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            if isFocused {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - OTP Input Field

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public struct OTPInputField: View {
    @Binding var otp: String
    let length: Int
    let onComplete: ((String) -> Void)?
    
    @FocusState private var fieldFocus: Int?
    @State private var digits: [String]
    
    public init(
        otp: Binding<String>,
        length: Int = 6,
        onComplete: ((String) -> Void)? = nil
    ) {
        self._otp = otp
        self.length = length
        self.onComplete = onComplete
        self._digits = State(initialValue: Array(repeating: "", count: length))
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<length, id: \.self) { index in
                TextField("", text: $digits[index])
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(width: 45, height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(fieldFocus == index ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .focused($fieldFocus, equals: index)
                    .onChange(of: digits[index]) { _, newValue in
                        if newValue.count > 1 {
                            digits[index] = String(newValue.prefix(1))
                        }
                        
                        if !newValue.isEmpty && index < length - 1 {
                            fieldFocus = index + 1
                        }
                        
                        otp = digits.joined()
                        
                        if digits.allSatisfy({ !$0.isEmpty }) {
                            onComplete?(otp)
                        }
                    }
            }
        }
        .onAppear {
            fieldFocus = 0
        }
    }
}