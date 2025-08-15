import SwiftUI
import SwiftIntelligencePrivacy
import SwiftIntelligenceCore
import LocalAuthentication

struct PrivacyDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var selectedFeature: PrivacyFeature = .encryption
    @State private var textToEncrypt: String = "This is sensitive information that needs to be encrypted securely."
    @State private var encryptionResults: [PrivacyResult] = []
    @State private var isProcessing = false
    @State private var biometricAuthResult: String = ""
    @State private var selectedEncryptionLevel: EncryptionLevel = .aes256
    @State private var showingDataMask = false
    @State private var sensitiveData: String = "John.Doe@email.com, Phone: +1-555-123-4567, SSN: 123-45-6789"
    @State private var maskedData: String = ""
    
    enum PrivacyFeature: String, CaseIterable {
        case encryption = "Data Encryption"
        case biometric = "Biometric Authentication"
        case dataMasking = "Data Masking & Anonymization"
        case secureStorage = "Secure Storage"
        case privacyAnalysis = "Privacy Analysis"
        case compliance = "Compliance Check"
        
        var icon: String {
            switch self {
            case .encryption: return "lock.shield"
            case .biometric: return "faceid"
            case .dataMasking: return "eye.slash"
            case .secureStorage: return "externaldrive.fill.badge.checkmark"
            case .privacyAnalysis: return "magnifyingglass.circle"
            case .compliance: return "checkmark.shield"
            }
        }
        
        var description: String {
            switch self {
            case .encryption: return "Advanced encryption algorithms for data protection"
            case .biometric: return "Face ID, Touch ID, and other biometric authentication"
            case .dataMasking: return "Mask and anonymize sensitive personal information"
            case .secureStorage: return "Encrypted storage with access controls"
            case .privacyAnalysis: return "Analyze data for privacy risks and vulnerabilities"
            case .compliance: return "Check compliance with GDPR, CCPA, and other regulations"
            }
        }
        
        var color: Color {
            switch self {
            case .encryption: return .blue
            case .biometric: return .green
            case .dataMasking: return .orange
            case .secureStorage: return .purple
            case .privacyAnalysis: return .red
            case .compliance: return .indigo
            }
        }
    }
    
    enum EncryptionLevel: String, CaseIterable {
        case aes128 = "AES-128"
        case aes256 = "AES-256"
        case chacha20 = "ChaCha20-Poly1305"
        case rsa2048 = "RSA-2048"
        case ellipticCurve = "Elliptic Curve P-256"
        
        var description: String {
            switch self {
            case .aes128: return "Fast symmetric encryption, good security"
            case .aes256: return "Strong symmetric encryption, industry standard"
            case .chacha20: return "Modern stream cipher, excellent performance"
            case .rsa2048: return "Public key encryption, key exchange"
            case .ellipticCurve: return "Modern public key, compact keys"
            }
        }
        
        var strength: String {
            switch self {
            case .aes128: return "Good"
            case .aes256: return "Excellent"
            case .chacha20: return "Excellent"
            case .rsa2048: return "Very Good"
            case .ellipticCurve: return "Excellent"
            }
        }
    }
    
    struct PrivacyResult: Identifiable {
        let id = UUID()
        let feature: PrivacyFeature
        let operation: String
        let result: String
        let details: [String: String]
        let timestamp: Date
        let duration: TimeInterval
        let success: Bool
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.mint)
                            .font(.title)
                        Text("Privacy & Security Engine")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Advanced privacy protection, encryption, and security compliance tools")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Feature Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Features")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(PrivacyFeature.allCases, id: \.rawValue) { feature in
                            Button(action: {
                                selectedFeature = feature
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: feature.icon)
                                        .font(.title2)
                                        .foregroundColor(selectedFeature == feature ? .white : feature.color)
                                    Text(feature.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedFeature == feature ? .white : .primary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(height: 70)
                                .frame(maxWidth: .infinity)
                                .background(selectedFeature == feature ? feature.color : feature.color.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Text(selectedFeature.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
                
                Divider()
                
                // Feature-Specific UI
                switch selectedFeature {
                case .encryption:
                    encryptionSection
                case .biometric:
                    biometricSection
                case .dataMasking:
                    dataMaskingSection
                case .secureStorage:
                    secureStorageSection
                case .privacyAnalysis:
                    privacyAnalysisSection
                case .compliance:
                    complianceSection
                }
                
                if !encryptionResults.isEmpty {
                    Divider()
                    
                    // Results History
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy Operations History")
                            .font(.headline)
                        
                        ForEach(encryptionResults.reversed()) { result in
                            PrivacyResultCard(result: result)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Engine")
    }
    
    // MARK: - Feature Sections
    
    private var encryptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Encryption & Decryption")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Encryption Level Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Encryption Algorithm:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(EncryptionLevel.allCases, id: \.rawValue) { level in
                                Button(action: {
                                    selectedEncryptionLevel = level
                                }) {
                                    VStack(spacing: 4) {
                                        Text(level.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Text(level.strength)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedEncryptionLevel == level ? Color.blue : Color.blue.opacity(0.1))
                                    .foregroundColor(selectedEncryptionLevel == level ? .white : .primary)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                    
                    Text(selectedEncryptionLevel.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
                
                // Text Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data to Encrypt:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $textToEncrypt)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Text("\(textToEncrypt.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Action Buttons
                HStack {
                    Button(action: {
                        Task {
                            await performEncryption()
                        }
                    }) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "lock.fill")
                            }
                            Text("Encrypt")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(isProcessing ? Color.gray : Color.blue)
                        .cornerRadius(8)
                    }
                    .disabled(isProcessing || textToEncrypt.isEmpty)
                    
                    Button(action: {
                        Task {
                            await performDecryption()
                        }
                    }) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Decrypt")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                    }
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var biometricSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Biometric Authentication")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available biometric authentication methods on this device:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(spacing: 8) {
                        BiometricCapabilityRow(
                            icon: "faceid",
                            title: "Face ID",
                            available: LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
                        )
                        
                        BiometricCapabilityRow(
                            icon: "touchid",
                            title: "Touch ID",
                            available: LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
                        )
                        
                        BiometricCapabilityRow(
                            icon: "key.fill",
                            title: "Device Passcode",
                            available: LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
                        )
                    }
                }
                
                Button(action: {
                    Task {
                        await performBiometricAuth()
                    }
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "faceid")
                        }
                        Text("Authenticate with Biometrics")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isProcessing ? Color.gray : Color.green)
                    .cornerRadius(10)
                }
                .disabled(isProcessing)
                
                if !biometricAuthResult.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Authentication Result:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(biometricAuthResult)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var dataMaskingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Masking & Anonymization")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sensitive Data:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $sensitiveData)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Text("Example data with email, phone, and SSN")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Button("Mask PII") {
                        Task {
                            await performDataMasking()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Anonymize") {
                        Task {
                            await performDataAnonymization()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
                
                if !maskedData.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Masked Data:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(maskedData)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var secureStorageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Secure Storage")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Manage encrypted storage for sensitive application data")
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    Button("Store Secure Data") {
                        Task {
                            await performSecureStorage()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Retrieve Secure Data") {
                        Task {
                            await performSecureRetrieval()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Clear Secure Storage") {
                        Task {
                            await performSecureClear()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var privacyAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Risk Analysis")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Analyze application data for privacy risks and compliance issues")
                    .foregroundColor(.secondary)
                
                Button("Run Privacy Scan") {
                    Task {
                        await performPrivacyAnalysis()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            }
        }
    }
    
    private var complianceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Regulatory Compliance")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Check compliance with GDPR, CCPA, HIPAA, and other privacy regulations")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    ComplianceButton(title: "GDPR Check", icon: "🇪🇺") {
                        Task {
                            await performGDPRCheck()
                        }
                    }
                    .disabled(isProcessing)
                    
                    ComplianceButton(title: "CCPA Check", icon: "🇺🇸") {
                        Task {
                            await performCCPACheck()
                        }
                    }
                    .disabled(isProcessing)
                    
                    ComplianceButton(title: "HIPAA Check", icon: "🏥") {
                        Task {
                            await performHIPAACheck()
                        }
                    }
                    .disabled(isProcessing)
                    
                    ComplianceButton(title: "SOC 2 Check", icon: "🔒") {
                        Task {
                            await performSOC2Check()
                        }
                    }
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    // MARK: - Privacy Operations
    
    @MainActor
    private func performEncryption() async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let request = EncryptionRequest(
                data: textToEncrypt,
                algorithm: getAlgorithmID(for: selectedEncryptionLevel),
                keySize: getKeySize(for: selectedEncryptionLevel)
            )
            
            let result = try await privacyEngine.encrypt(request: request)
            let duration = Date().timeIntervalSince(startTime)
            
            let privacyResult = PrivacyResult(
                feature: .encryption,
                operation: "Encrypt with \(selectedEncryptionLevel.rawValue)",
                result: "Data encrypted successfully",
                details: [
                    "Algorithm": selectedEncryptionLevel.rawValue,
                    "Key Size": "\(getKeySize(for: selectedEncryptionLevel)) bits",
                    "Encrypted Length": "\(result.encryptedData.count) bytes",
                    "Encryption ID": result.encryptionID
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            let errorResult = PrivacyResult(
                feature: .encryption,
                operation: "Encrypt with \(selectedEncryptionLevel.rawValue)",
                result: "Encryption failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performDecryption() async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            // Simulate decryption of previously encrypted data
            let decryptedText = try await privacyEngine.decrypt(encryptionID: "demo_encryption_id")
            let duration = Date().timeIntervalSince(startTime)
            
            let privacyResult = PrivacyResult(
                feature: .encryption,
                operation: "Decrypt",
                result: "Data decrypted successfully",
                details: [
                    "Original Length": "\(decryptedText.count) characters",
                    "Decrypted Text": decryptedText.prefix(50) + "..."
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            let errorResult = PrivacyResult(
                feature: .encryption,
                operation: "Decrypt",
                result: "Decryption failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performBiometricAuth() async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let authRequest = BiometricAuthRequest(
                reason: "Authenticate to access secure features",
                fallbackTitle: "Use Passcode",
                allowDevicePasscode: true
            )
            
            let result = try await privacyEngine.authenticateBiometric(request: authRequest)
            let duration = Date().timeIntervalSince(startTime)
            
            biometricAuthResult = result.success ? 
                "✅ Authentication successful! Method: \(result.method.rawValue)" :
                "❌ Authentication failed: \(result.error?.localizedDescription ?? "Unknown error")"
            
            let privacyResult = PrivacyResult(
                feature: .biometric,
                operation: "Biometric Authentication",
                result: biometricAuthResult,
                details: [
                    "Method": result.method.rawValue,
                    "Success": result.success ? "Yes" : "No",
                    "User ID": result.userID ?? "N/A"
                ],
                timestamp: Date(),
                duration: duration,
                success: result.success
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            biometricAuthResult = "❌ Authentication error: \(error.localizedDescription)"
            
            let errorResult = PrivacyResult(
                feature: .biometric,
                operation: "Biometric Authentication",
                result: biometricAuthResult,
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performDataMasking() async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let maskingRequest = DataMaskingRequest(
                data: sensitiveData,
                maskingRules: [.email, .phone, .ssn, .creditCard],
                preserveFormat: true
            )
            
            let result = try await privacyEngine.maskSensitiveData(request: maskingRequest)
            maskedData = result.maskedData
            let duration = Date().timeIntervalSince(startTime)
            
            let privacyResult = PrivacyResult(
                feature: .dataMasking,
                operation: "Data Masking",
                result: "Sensitive data masked successfully",
                details: [
                    "Items Masked": "\(result.maskedFields.count)",
                    "Masked Fields": result.maskedFields.joined(separator: ", "),
                    "Preservation Rate": "\(String(format: "%.1f%%", result.preservationRate * 100))"
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            let errorResult = PrivacyResult(
                feature: .dataMasking,
                operation: "Data Masking",
                result: "Masking failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performDataAnonymization() async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let anonymizeRequest = DataAnonymizationRequest(
                data: sensitiveData,
                anonymizationLevel: .high,
                preserveAnalytics: true
            )
            
            let result = try await privacyEngine.anonymizeData(request: anonymizeRequest)
            maskedData = result.anonymizedData
            let duration = Date().timeIntervalSince(startTime)
            
            let privacyResult = PrivacyResult(
                feature: .dataMasking,
                operation: "Data Anonymization",
                result: "Data anonymized successfully",
                details: [
                    "Anonymization Level": anonymizeRequest.anonymizationLevel.rawValue,
                    "Privacy Score": "\(String(format: "%.1f", result.privacyScore))",
                    "Utility Score": "\(String(format: "%.1f", result.utilityScore))"
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            let errorResult = PrivacyResult(
                feature: .dataMasking,
                operation: "Data Anonymization",
                result: "Anonymization failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performSecureStorage() async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let storageRequest = SecureStorageRequest(
                key: "demo_secure_key",
                data: textToEncrypt,
                accessControl: .biometricAny,
                encryption: .aes256GCM
            )
            
            try await privacyEngine.storeSecurely(request: storageRequest)
            let duration = Date().timeIntervalSince(startTime)
            
            let privacyResult = PrivacyResult(
                feature: .secureStorage,
                operation: "Secure Storage",
                result: "Data stored securely",
                details: [
                    "Storage Key": "demo_secure_key",
                    "Access Control": "Biometric",
                    "Encryption": "AES-256-GCM",
                    "Data Size": "\(textToEncrypt.count) bytes"
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            let errorResult = PrivacyResult(
                feature: .secureStorage,
                operation: "Secure Storage",
                result: "Storage failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performSecureRetrieval() async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let retrievalRequest = SecureRetrievalRequest(
                key: "demo_secure_key",
                authenticationPrompt: "Authenticate to retrieve secure data"
            )
            
            let result = try await privacyEngine.retrieveSecurely(request: retrievalRequest)
            let duration = Date().timeIntervalSince(startTime)
            
            let privacyResult = PrivacyResult(
                feature: .secureStorage,
                operation: "Secure Retrieval",
                result: "Data retrieved successfully",
                details: [
                    "Retrieved Size": "\(result.data.count) bytes",
                    "Access Method": result.authMethod.rawValue,
                    "Retrieved Data": String(result.data.prefix(50)) + "..."
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            let errorResult = PrivacyResult(
                feature: .secureStorage,
                operation: "Secure Retrieval",
                result: "Retrieval failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performSecureClear() async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            try await privacyEngine.clearSecureStorage(key: "demo_secure_key")
            let duration = Date().timeIntervalSince(startTime)
            
            let privacyResult = PrivacyResult(
                feature: .secureStorage,
                operation: "Clear Storage",
                result: "Secure storage cleared",
                details: [
                    "Cleared Key": "demo_secure_key"
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            let errorResult = PrivacyResult(
                feature: .secureStorage,
                operation: "Clear Storage",
                result: "Clear failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performPrivacyAnalysis() async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let analysisRequest = PrivacyAnalysisRequest(
                dataTypes: [.personalInfo, .location, .device, .usage],
                analysisDepth: .comprehensive,
                includeRecommendations: true
            )
            
            let result = try await privacyEngine.analyzePrivacyRisks(request: analysisRequest)
            let duration = Date().timeIntervalSince(startTime)
            
            let privacyResult = PrivacyResult(
                feature: .privacyAnalysis,
                operation: "Privacy Risk Analysis",
                result: "Analysis completed - Risk Level: \(result.riskLevel.rawValue)",
                details: [
                    "Risk Score": "\(String(format: "%.1f/10", result.riskScore))",
                    "Vulnerabilities": "\(result.vulnerabilities.count)",
                    "Recommendations": "\(result.recommendations.count)",
                    "Compliance Score": "\(String(format: "%.1f%%", result.complianceScore * 100))"
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            let errorResult = PrivacyResult(
                feature: .privacyAnalysis,
                operation: "Privacy Risk Analysis",
                result: "Analysis failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performGDPRCheck() async {
        await performComplianceCheck(regulation: .gdpr, title: "GDPR Compliance Check")
    }
    
    @MainActor
    private func performCCPACheck() async {
        await performComplianceCheck(regulation: .ccpa, title: "CCPA Compliance Check")
    }
    
    @MainActor
    private func performHIPAACheck() async {
        await performComplianceCheck(regulation: .hipaa, title: "HIPAA Compliance Check")
    }
    
    @MainActor
    private func performSOC2Check() async {
        await performComplianceCheck(regulation: .soc2, title: "SOC 2 Compliance Check")
    }
    
    @MainActor
    private func performComplianceCheck(regulation: ComplianceRegulation, title: String) async {
        guard let privacyEngine = appManager.getPrivacyEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let complianceRequest = ComplianceCheckRequest(
                regulation: regulation,
                dataTypes: [.personalInfo, .sensitive, .financial],
                checkLevel: .comprehensive
            )
            
            let result = try await privacyEngine.checkCompliance(request: complianceRequest)
            let duration = Date().timeIntervalSince(startTime)
            
            let privacyResult = PrivacyResult(
                feature: .compliance,
                operation: title,
                result: result.isCompliant ? "✅ Compliant" : "⚠️ Non-compliant",
                details: [
                    "Regulation": regulation.rawValue,
                    "Compliance Score": "\(String(format: "%.1f%%", result.complianceScore * 100))",
                    "Issues Found": "\(result.issues.count)",
                    "Requirements Met": "\(result.metRequirements)/\(result.totalRequirements)"
                ],
                timestamp: Date(),
                duration: duration,
                success: result.isCompliant
            )
            
            encryptionResults.insert(privacyResult, at: 0)
            
        } catch {
            let errorResult = PrivacyResult(
                feature: .compliance,
                operation: title,
                result: "Check failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            encryptionResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    // MARK: - Helper Methods
    
    private func getAlgorithmID(for level: EncryptionLevel) -> String {
        switch level {
        case .aes128: return "aes_128_gcm"
        case .aes256: return "aes_256_gcm"
        case .chacha20: return "chacha20_poly1305"
        case .rsa2048: return "rsa_2048"
        case .ellipticCurve: return "ec_p256"
        }
    }
    
    private func getKeySize(for level: EncryptionLevel) -> Int {
        switch level {
        case .aes128: return 128
        case .aes256: return 256
        case .chacha20: return 256
        case .rsa2048: return 2048
        case .ellipticCurve: return 256
        }
    }
}

struct PrivacyResultCard: View {
    let result: PrivacyDemoView.PrivacyResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.feature.icon)
                    .foregroundColor(result.feature.color)
                VStack(alignment: .leading) {
                    Text(result.operation)
                        .font(.headline)
                    Text(timeAgoString(from: result.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.success ? .green : .red)
            }
            
            Text(result.result)
                .font(.body)
                .padding(10)
                .background(result.feature.color.opacity(0.1))
                .cornerRadius(8)
            
            if !result.details.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Details:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(result.details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key + ":")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(value)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(6)
            }
            
            HStack {
                Spacer()
                Text(String(format: "%.3fs", result.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct BiometricCapabilityRow: View {
    let icon: String
    let title: String
    let available: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(available ? .green : .gray)
            Text(title)
                .foregroundColor(available ? .primary : .secondary)
            Spacer()
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(available ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

struct ComplianceButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.indigo.opacity(0.1))
            .cornerRadius(8)
        }
    }
}