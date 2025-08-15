import SwiftUI
import SwiftIntelligenceNetwork
import SwiftIntelligenceCore

struct NetworkDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var selectedFeature: NetworkFeature = .httpClient
    @State private var isProcessing = false
    @State private var networkResults: [NetworkResult] = []
    
    // HTTP Client states
    @State private var httpURL: String = "https://jsonplaceholder.typicode.com/posts/1"
    @State private var httpMethod: HTTPMethodType = .get
    @State private var requestBody: String = ""
    @State private var httpHeaders: String = "Content-Type: application/json\nAuthorization: Bearer token123"
    
    // WebSocket states
    @State private var websocketURL: String = "wss://echo.websocket.org"
    @State private var isWebSocketConnected = false
    @State private var websocketMessage: String = "Hello WebSocket!"
    @State private var websocketMessages: [String] = []
    
    // GraphQL states
    @State private var graphqlEndpoint: String = "https://api.github.com/graphql"
    @State private var graphqlQuery: String = """
    {
      viewer {
        login
        name
        email
      }
    }
    """
    @State private var graphqlVariables: String = "{}"
    
    enum NetworkFeature: String, CaseIterable {
        case httpClient = "HTTP Client"
        case websocket = "WebSocket"
        case graphql = "GraphQL"
        case fileUpload = "File Upload"
        case networkMonitor = "Network Monitor"
        case apiTesting = "API Testing"
        
        var icon: String {
            switch self {
            case .httpClient: return "network"
            case .websocket: return "bolt.horizontal"
            case .graphql: return "graphql"
            case .fileUpload: return "icloud.and.arrow.up"
            case .networkMonitor: return "wifi"
            case .apiTesting: return "checkmark.circle"
            }
        }
        
        var description: String {
            switch self {
            case .httpClient: return "RESTful API calls with HTTP/HTTPS support"
            case .websocket: return "Real-time bidirectional communication"
            case .graphql: return "Flexible GraphQL queries and mutations"
            case .fileUpload: return "Upload files with progress tracking"
            case .networkMonitor: return "Monitor network connectivity and performance"
            case .apiTesting: return "Test API endpoints and validate responses"
            }
        }
        
        var color: Color {
            switch self {
            case .httpClient: return .blue
            case .websocket: return .green
            case .graphql: return .purple
            case .fileUpload: return .orange
            case .networkMonitor: return .cyan
            case .apiTesting: return .red
            }
        }
    }
    
    enum HTTPMethodType: String, CaseIterable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
        case head = "HEAD"
        case options = "OPTIONS"
        
        var color: Color {
            switch self {
            case .get: return .blue
            case .post: return .green
            case .put: return .orange
            case .delete: return .red
            case .patch: return .purple
            case .head: return .gray
            case .options: return .cyan
            }
        }
    }
    
    struct NetworkResult: Identifiable {
        let id = UUID()
        let feature: NetworkFeature
        let operation: String
        let result: String
        let details: [String: String]
        let timestamp: Date
        let duration: TimeInterval
        let statusCode: Int?
        let success: Bool
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(.teal)
                            .font(.title)
                        Text("Network & API Engine")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Comprehensive networking capabilities with HTTP, WebSocket, and GraphQL support")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Feature Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Network Features")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(NetworkFeature.allCases, id: \.rawValue) { feature in
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
                case .httpClient:
                    httpClientSection
                case .websocket:
                    websocketSection
                case .graphql:
                    graphqlSection
                case .fileUpload:
                    fileUploadSection
                case .networkMonitor:
                    networkMonitorSection
                case .apiTesting:
                    apiTestingSection
                }
                
                if !networkResults.isEmpty {
                    Divider()
                    
                    // Results History
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Network Operations History")
                            .font(.headline)
                        
                        ForEach(networkResults.reversed()) { result in
                            NetworkResultCard(result: result)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Network Engine")
    }
    
    // MARK: - Feature Sections
    
    private var httpClientSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("HTTP Client")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // HTTP Method Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("HTTP Method:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(HTTPMethodType.allCases, id: \.rawValue) { method in
                                Button(action: {
                                    httpMethod = method
                                }) {
                                    Text(method.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(httpMethod == method ? method.color : method.color.opacity(0.1))
                                        .foregroundColor(httpMethod == method ? .white : .primary)
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                // URL Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Request URL:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter API endpoint URL", text: $httpURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                // Headers Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Headers (one per line):")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $httpHeaders)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .font(.system(.caption, design: .monospaced))
                }
                
                // Request Body (for POST, PUT, PATCH)
                if [.post, .put, .patch].contains(httpMethod) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Request Body (JSON):")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextEditor(text: $requestBody)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .font(.system(.caption, design: .monospaced))
                        
                        // Sample JSON buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(sampleJSONBodies, id: \.title) { sample in
                                    Button(sample.title) {
                                        requestBody = sample.json
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                }
                
                // Send Request Button
                Button(action: {
                    Task {
                        await performHTTPRequest()
                    }
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        Text(isProcessing ? "Sending..." : "Send Request")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isProcessing ? Color.gray : httpMethod.color)
                    .cornerRadius(10)
                }
                .disabled(isProcessing || httpURL.isEmpty)
            }
        }
    }
    
    private var websocketSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WebSocket Connection")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // WebSocket URL Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("WebSocket URL:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter WebSocket URL", text: $websocketURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                // Connection Status
                HStack {
                    Text("Status:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(isWebSocketConnected ? "Connected" : "Disconnected")
                        .foregroundColor(isWebSocketConnected ? .green : .red)
                        .fontWeight(.medium)
                    Spacer()
                    Circle()
                        .fill(isWebSocketConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                }
                
                // Connection Buttons
                HStack {
                    Button(action: {
                        Task {
                            await connectWebSocket()
                        }
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("Connect")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(isWebSocketConnected ? Color.gray : Color.green)
                        .cornerRadius(8)
                    }
                    .disabled(isWebSocketConnected || isProcessing)
                    
                    Button(action: {
                        Task {
                            await disconnectWebSocket()
                        }
                    }) {
                        HStack {
                            Image(systemName: "link.badge.minus")
                            Text("Disconnect")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(isWebSocketConnected ? Color.red : Color.gray)
                        .cornerRadius(8)
                    }
                    .disabled(!isWebSocketConnected || isProcessing)
                }
                
                // Message Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message to Send:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        TextField("Enter message", text: $websocketMessage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Send") {
                            Task {
                                await sendWebSocketMessage()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!isWebSocketConnected || websocketMessage.isEmpty || isProcessing)
                    }
                }
                
                // Received Messages
                if !websocketMessages.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Received Messages:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(websocketMessages.reversed(), id: \.self) { message in
                                    Text(message)
                                        .font(.caption)
                                        .padding(8)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(6)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var graphqlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GraphQL Client")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // GraphQL Endpoint
                VStack(alignment: .leading, spacing: 8) {
                    Text("GraphQL Endpoint:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter GraphQL endpoint", text: $graphqlEndpoint)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                // GraphQL Query
                VStack(alignment: .leading, spacing: 8) {
                    Text("GraphQL Query/Mutation:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $graphqlQuery)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .font(.system(.caption, design: .monospaced))
                    
                    // Sample GraphQL queries
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(sampleGraphQLQueries, id: \.title) { sample in
                                Button(sample.title) {
                                    graphqlQuery = sample.query
                                }
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                // GraphQL Variables
                VStack(alignment: .leading, spacing: 8) {
                    Text("Variables (JSON):")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $graphqlVariables)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .font(.system(.caption, design: .monospaced))
                }
                
                // Execute Query Button
                Button(action: {
                    Task {
                        await executeGraphQLQuery()
                    }
                }) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "play.fill")
                        }
                        Text(isProcessing ? "Executing..." : "Execute Query")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isProcessing ? Color.gray : Color.purple)
                    .cornerRadius(10)
                }
                .disabled(isProcessing || graphqlEndpoint.isEmpty || graphqlQuery.isEmpty)
            }
        }
    }
    
    private var fileUploadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("File Upload")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Upload files with progress tracking and metadata")
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    Button("Select & Upload Image") {
                        Task {
                            await performFileUpload(type: .image)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Select & Upload Document") {
                        Task {
                            await performFileUpload(type: .document)
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Upload Large File (Mock)") {
                        Task {
                            await performFileUpload(type: .largeFile)
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var networkMonitorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Network Monitor")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Monitor network connectivity, speed, and performance")
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    Button("Check Network Status") {
                        Task {
                            await checkNetworkStatus()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Test Connection Speed") {
                        Task {
                            await testConnectionSpeed()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Monitor Real-time") {
                        Task {
                            await startNetworkMonitoring()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var apiTestingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("API Testing")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Test API endpoints and validate responses")
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    Button("Test JSONPlaceholder API") {
                        Task {
                            await testJSONPlaceholderAPI()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Test GitHub API") {
                        Task {
                            await testGitHubAPI()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Performance Benchmark") {
                        Task {
                            await performAPIBenchmark()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    // MARK: - Sample Data
    
    private var sampleJSONBodies: [(title: String, json: String)] {
        [
            ("User Post", """
            {
              "title": "Sample Post",
              "body": "This is a sample post body",
              "userId": 1
            }
            """),
            ("User Profile", """
            {
              "name": "John Doe",
              "email": "john@example.com",
              "age": 30
            }
            """),
            ("Product Data", """
            {
              "name": "iPhone 15",
              "price": 999.99,
              "category": "Electronics"
            }
            """)
        ]
    }
    
    private var sampleGraphQLQueries: [(title: String, query: String)] {
        [
            ("User Query", """
            query GetUser($id: ID!) {
              user(id: $id) {
                id
                name
                email
                posts {
                  title
                  content
                }
              }
            }
            """),
            ("Posts List", """
            query GetPosts($limit: Int) {
              posts(limit: $limit) {
                id
                title
                author {
                  name
                }
                createdAt
              }
            }
            """),
            ("Create Post", """
            mutation CreatePost($input: PostInput!) {
              createPost(input: $input) {
                id
                title
                content
                author {
                  name
                }
              }
            }
            """)
        ]
    }
    
    // MARK: - Network Operations
    
    @MainActor
    private func performHTTPRequest() async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let request = HTTPRequest(
                url: httpURL,
                method: HTTPMethod(rawValue: httpMethod.rawValue) ?? .get,
                headers: parseHeaders(httpHeaders),
                body: httpMethod.rawValue == "GET" ? nil : requestBody.data(using: .utf8),
                timeout: 30.0
            )
            
            let response = try await networkEngine.performHTTPRequest(request: request)
            let duration = Date().timeIntervalSince(startTime)
            
            let networkResult = NetworkResult(
                feature: .httpClient,
                operation: "\(httpMethod.rawValue) \(httpURL)",
                result: "Request completed successfully",
                details: [
                    "Status Code": "\(response.statusCode)",
                    "Response Size": "\(response.data.count) bytes",
                    "Content Type": response.headers["Content-Type"] ?? "Unknown",
                    "Response Preview": String(data: response.data.prefix(200), encoding: .utf8) ?? "Binary data"
                ],
                timestamp: Date(),
                duration: duration,
                statusCode: response.statusCode,
                success: (200...299).contains(response.statusCode)
            )
            
            networkResults.insert(networkResult, at: 0)
            
        } catch {
            let errorResult = NetworkResult(
                feature: .httpClient,
                operation: "\(httpMethod.rawValue) \(httpURL)",
                result: "Request failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func connectWebSocket() async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let wsRequest = WebSocketRequest(
                url: websocketURL,
                protocols: [],
                headers: [:]
            )
            
            try await networkEngine.connectWebSocket(request: wsRequest)
            isWebSocketConnected = true
            let duration = Date().timeIntervalSince(startTime)
            
            let networkResult = NetworkResult(
                feature: .websocket,
                operation: "Connect to \(websocketURL)",
                result: "WebSocket connected successfully",
                details: [
                    "URL": websocketURL,
                    "Connection Time": String(format: "%.2fs", duration)
                ],
                timestamp: Date(),
                duration: duration,
                statusCode: nil,
                success: true
            )
            
            networkResults.insert(networkResult, at: 0)
            
        } catch {
            let errorResult = NetworkResult(
                feature: .websocket,
                operation: "Connect to \(websocketURL)",
                result: "Connection failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func disconnectWebSocket() async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        
        do {
            try await networkEngine.disconnectWebSocket()
            isWebSocketConnected = false
            
            let networkResult = NetworkResult(
                feature: .websocket,
                operation: "Disconnect WebSocket",
                result: "WebSocket disconnected successfully",
                details: [:],
                timestamp: Date(),
                duration: 0.0,
                statusCode: nil,
                success: true
            )
            
            networkResults.insert(networkResult, at: 0)
            
        } catch {
            let errorResult = NetworkResult(
                feature: .websocket,
                operation: "Disconnect WebSocket",
                result: "Disconnect failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: 0.0,
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func sendWebSocketMessage() async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        
        do {
            try await networkEngine.sendWebSocketMessage(websocketMessage)
            websocketMessages.append("Sent: \(websocketMessage)")
            
            // Simulate receiving echo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.websocketMessages.append("Received: \(self.websocketMessage)")
            }
            
            let networkResult = NetworkResult(
                feature: .websocket,
                operation: "Send Message",
                result: "Message sent successfully",
                details: [
                    "Message": websocketMessage,
                    "Length": "\(websocketMessage.count) characters"
                ],
                timestamp: Date(),
                duration: 0.1,
                statusCode: nil,
                success: true
            )
            
            networkResults.insert(networkResult, at: 0)
            websocketMessage = ""
            
        } catch {
            let errorResult = NetworkResult(
                feature: .websocket,
                operation: "Send Message",
                result: "Send failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: 0.0,
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func executeGraphQLQuery() async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let variables = parseGraphQLVariables(graphqlVariables)
            let gqlRequest = GraphQLRequest(
                endpoint: graphqlEndpoint,
                query: graphqlQuery,
                variables: variables,
                headers: ["Content-Type": "application/json"]
            )
            
            let response = try await networkEngine.executeGraphQLQuery(request: gqlRequest)
            let duration = Date().timeIntervalSince(startTime)
            
            let networkResult = NetworkResult(
                feature: .graphql,
                operation: "GraphQL Query",
                result: "Query executed successfully",
                details: [
                    "Endpoint": graphqlEndpoint,
                    "Query Type": detectQueryType(graphqlQuery),
                    "Variables": variables.isEmpty ? "None" : "\(variables.count) variables",
                    "Response Size": "\(response.data.count) bytes",
                    "Has Errors": response.errors.isEmpty ? "No" : "Yes"
                ],
                timestamp: Date(),
                duration: duration,
                statusCode: nil,
                success: response.errors.isEmpty
            )
            
            networkResults.insert(networkResult, at: 0)
            
        } catch {
            let errorResult = NetworkResult(
                feature: .graphql,
                operation: "GraphQL Query",
                result: "Query failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performFileUpload(type: FileUploadType) async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let (fileData, fileName, mimeType) = generateMockFileData(for: type)
            
            let uploadRequest = FileUploadRequest(
                url: "https://httpbin.org/post",
                fileData: fileData,
                fileName: fileName,
                mimeType: mimeType,
                additionalFields: ["description": "Test upload from SwiftIntelligence"]
            )
            
            let response = try await networkEngine.uploadFile(request: uploadRequest)
            let duration = Date().timeIntervalSince(startTime)
            
            let networkResult = NetworkResult(
                feature: .fileUpload,
                operation: "Upload \(type.rawValue)",
                result: "File uploaded successfully",
                details: [
                    "File Name": fileName,
                    "File Size": "\(fileData.count) bytes",
                    "MIME Type": mimeType,
                    "Upload ID": response.uploadID,
                    "Server Response": response.serverResponse
                ],
                timestamp: Date(),
                duration: duration,
                statusCode: response.statusCode,
                success: (200...299).contains(response.statusCode)
            )
            
            networkResults.insert(networkResult, at: 0)
            
        } catch {
            let errorResult = NetworkResult(
                feature: .fileUpload,
                operation: "Upload \(type.rawValue)",
                result: "Upload failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func checkNetworkStatus() async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let status = try await networkEngine.getNetworkStatus()
            let duration = Date().timeIntervalSince(startTime)
            
            let networkResult = NetworkResult(
                feature: .networkMonitor,
                operation: "Network Status Check",
                result: "Status: \(status.connectionType.rawValue)",
                details: [
                    "Connection Type": status.connectionType.rawValue,
                    "Is Connected": status.isConnected ? "Yes" : "No",
                    "Signal Strength": "\(status.signalStrength)%",
                    "Bandwidth": status.estimatedBandwidth,
                    "IP Address": status.ipAddress ?? "Unknown"
                ],
                timestamp: Date(),
                duration: duration,
                statusCode: nil,
                success: status.isConnected
            )
            
            networkResults.insert(networkResult, at: 0)
            
        } catch {
            let errorResult = NetworkResult(
                feature: .networkMonitor,
                operation: "Network Status Check",
                result: "Status check failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func testConnectionSpeed() async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let speedTest = try await networkEngine.testConnectionSpeed()
            let duration = Date().timeIntervalSince(startTime)
            
            let networkResult = NetworkResult(
                feature: .networkMonitor,
                operation: "Connection Speed Test",
                result: "Test completed successfully",
                details: [
                    "Download Speed": String(format: "%.2f Mbps", speedTest.downloadSpeed),
                    "Upload Speed": String(format: "%.2f Mbps", speedTest.uploadSpeed),
                    "Latency": String(format: "%.0f ms", speedTest.latency),
                    "Jitter": String(format: "%.2f ms", speedTest.jitter),
                    "Test Server": speedTest.serverLocation
                ],
                timestamp: Date(),
                duration: duration,
                statusCode: nil,
                success: true
            )
            
            networkResults.insert(networkResult, at: 0)
            
        } catch {
            let errorResult = NetworkResult(
                feature: .networkMonitor,
                operation: "Connection Speed Test",
                result: "Speed test failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func startNetworkMonitoring() async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        
        do {
            try await networkEngine.startNetworkMonitoring { status in
                DispatchQueue.main.async {
                    let networkResult = NetworkResult(
                        feature: .networkMonitor,
                        operation: "Real-time Monitoring",
                        result: "Network status updated",
                        details: [
                            "Connection": status.connectionType.rawValue,
                            "Signal": "\(status.signalStrength)%",
                            "Bandwidth": status.estimatedBandwidth
                        ],
                        timestamp: Date(),
                        duration: 0.0,
                        statusCode: nil,
                        success: status.isConnected
                    )
                    
                    self.networkResults.insert(networkResult, at: 0)
                }
            }
            
        } catch {
            let errorResult = NetworkResult(
                feature: .networkMonitor,
                operation: "Start Monitoring",
                result: "Monitoring failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: 0.0,
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func testJSONPlaceholderAPI() async {
        await performAPITest(
            name: "JSONPlaceholder API",
            url: "https://jsonplaceholder.typicode.com/posts/1",
            expectedStatus: 200
        )
    }
    
    @MainActor
    private func testGitHubAPI() async {
        await performAPITest(
            name: "GitHub API",
            url: "https://api.github.com/users/octocat",
            expectedStatus: 200
        )
    }
    
    @MainActor
    private func performAPIBenchmark() async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let benchmarkRequest = APIBenchmarkRequest(
                baseURL: "https://jsonplaceholder.typicode.com",
                endpoints: ["/posts/1", "/users/1", "/albums/1"],
                iterations: 10,
                concurrency: 3
            )
            
            let benchmark = try await networkEngine.runAPIBenchmark(request: benchmarkRequest)
            let duration = Date().timeIntervalSince(startTime)
            
            let networkResult = NetworkResult(
                feature: .apiTesting,
                operation: "API Performance Benchmark",
                result: "Benchmark completed successfully",
                details: [
                    "Total Requests": "\(benchmark.totalRequests)",
                    "Success Rate": String(format: "%.1f%%", benchmark.successRate * 100),
                    "Average Response Time": String(format: "%.0f ms", benchmark.averageResponseTime),
                    "Min Response Time": String(format: "%.0f ms", benchmark.minResponseTime),
                    "Max Response Time": String(format: "%.0f ms", benchmark.maxResponseTime),
                    "Requests per Second": String(format: "%.1f", benchmark.requestsPerSecond)
                ],
                timestamp: Date(),
                duration: duration,
                statusCode: nil,
                success: benchmark.successRate > 0.95
            )
            
            networkResults.insert(networkResult, at: 0)
            
        } catch {
            let errorResult = NetworkResult(
                feature: .apiTesting,
                operation: "API Performance Benchmark",
                result: "Benchmark failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performAPITest(name: String, url: String, expectedStatus: Int) async {
        guard let networkEngine = appManager.getNetworkEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let request = HTTPRequest(
                url: url,
                method: .get,
                headers: [:],
                body: nil,
                timeout: 10.0
            )
            
            let response = try await networkEngine.performHTTPRequest(request: request)
            let duration = Date().timeIntervalSince(startTime)
            let success = response.statusCode == expectedStatus
            
            let networkResult = NetworkResult(
                feature: .apiTesting,
                operation: "Test \(name)",
                result: success ? "API test passed" : "API test failed",
                details: [
                    "Expected Status": "\(expectedStatus)",
                    "Actual Status": "\(response.statusCode)",
                    "Response Size": "\(response.data.count) bytes",
                    "Response Time": String(format: "%.0f ms", duration * 1000),
                    "Content Type": response.headers["Content-Type"] ?? "Unknown"
                ],
                timestamp: Date(),
                duration: duration,
                statusCode: response.statusCode,
                success: success
            )
            
            networkResults.insert(networkResult, at: 0)
            
        } catch {
            let errorResult = NetworkResult(
                feature: .apiTesting,
                operation: "Test \(name)",
                result: "API test failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                statusCode: nil,
                success: false
            )
            networkResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    // MARK: - Helper Methods
    
    private func parseHeaders(_ headerText: String) -> [String: String] {
        var headers: [String: String] = [:]
        let lines = headerText.components(separatedBy: .newlines)
        
        for line in lines {
            let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            if components.count == 2 {
                let key = String(components[0]).trimmingCharacters(in: .whitespaces)
                let value = String(components[1]).trimmingCharacters(in: .whitespaces)
                headers[key] = value
            }
        }
        
        return headers
    }
    
    private func parseGraphQLVariables(_ variablesText: String) -> [String: String] {
        // Simple JSON parsing for demo purposes
        // In a real app, you'd use JSONSerialization
        if variablesText.trimmingCharacters(in: .whitespacesAndNewlines) == "{}" {
            return [:]
        }
        
        return ["userId": "1", "limit": "10"] // Mock variables
    }
    
    private func detectQueryType(_ query: String) -> String {
        if query.lowercased().contains("mutation") {
            return "Mutation"
        } else if query.lowercased().contains("subscription") {
            return "Subscription"
        } else {
            return "Query"
        }
    }
    
    private enum FileUploadType: String {
        case image = "Image"
        case document = "Document"
        case largeFile = "Large File"
    }
    
    private func generateMockFileData(for type: FileUploadType) -> (Data, String, String) {
        switch type {
        case .image:
            let data = "Mock image data".data(using: .utf8) ?? Data()
            return (data, "sample-image.jpg", "image/jpeg")
        case .document:
            let data = "Mock document content".data(using: .utf8) ?? Data()
            return (data, "sample-document.pdf", "application/pdf")
        case .largeFile:
            let data = String(repeating: "Large file content ", count: 1000).data(using: .utf8) ?? Data()
            return (data, "large-file.txt", "text/plain")
        }
    }
}

struct NetworkResultCard: View {
    let result: NetworkDemoView.NetworkResult
    
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
                HStack {
                    if let statusCode = result.statusCode {
                        Text("\(statusCode)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(getStatusColor(statusCode).opacity(0.2))
                            .foregroundColor(getStatusColor(statusCode))
                            .cornerRadius(4)
                    }
                    Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(result.success ? .green : .red)
                }
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
                        HStack(alignment: .top) {
                            Text(key + ":")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 100, alignment: .leading)
                            Text(value)
                                .font(.caption)
                                .fontWeight(.medium)
                            Spacer()
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
    
    private func getStatusColor(_ statusCode: Int) -> Color {
        switch statusCode {
        case 200...299: return .green
        case 300...399: return .orange
        case 400...499: return .red
        case 500...599: return .purple
        default: return .gray
        }
    }
}