//
// RateLimiter.swift
// SwiftIntelligence Server Integration
//
// Rate limiting implementation for API calls
//

import Foundation

/// Token bucket rate limiter for controlling API request rates
public actor RateLimiter {
    
    // MARK: - Properties
    
    private let requestsPerSecond: Int
    private let burstSize: Int
    private var availableTokens: Int
    private var lastRefillTime: Date
    
    private var waitingRequests: [CheckedContinuation<Void, Error>] = []
    
    // MARK: - Initialization
    
    public init(requestsPerSecond: Int, burstSize: Int) {
        self.requestsPerSecond = requestsPerSecond
        self.burstSize = burstSize
        self.availableTokens = burstSize
        self.lastRefillTime = Date()
    }
    
    // MARK: - Public Methods
    
    /// Wait for permission to make a request
    public func waitForPermission() async throws {
        refillTokens()
        
        if availableTokens > 0 {
            availableTokens -= 1
            return
        }
        
        // Wait for token to become available
        return try await withCheckedThrowingContinuation { continuation in
            waitingRequests.append(continuation)
            scheduleNextToken()
        }
    }
    
    /// Check if request can be made without waiting
    public func canMakeRequest() -> Bool {
        refillTokens()
        return availableTokens > 0
    }
    
    /// Reset the rate limiter
    public func reset() {
        availableTokens = burstSize
        lastRefillTime = Date()
        
        // Resume all waiting requests
        for continuation in waitingRequests {
            continuation.resume()
        }
        waitingRequests.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func refillTokens() {
        let now = Date()
        let timePassed = now.timeIntervalSince(lastRefillTime)
        let tokensToAdd = Int(timePassed * Double(requestsPerSecond))
        
        if tokensToAdd > 0 {
            availableTokens = min(availableTokens + tokensToAdd, burstSize)
            lastRefillTime = now
        }
    }
    
    private func scheduleNextToken() {
        Task {
            let waitTime = 1.0 / Double(requestsPerSecond)
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            
            await addToken()
        }
    }
    
    private func addToken() {
        availableTokens = min(availableTokens + 1, burstSize)
        
        if !waitingRequests.isEmpty {
            let continuation = waitingRequests.removeFirst()
            continuation.resume()
        }
    }
}

// MARK: - Circuit Breaker

/// Circuit breaker for fault tolerance
public actor CircuitBreaker {
    
    // MARK: - State
    
    public enum State {
        case closed     // Normal operation
        case open       // Failing, reject requests
        case halfOpen   // Testing if service recovered
    }
    
    // MARK: - Properties
    
    private var state: State = .closed
    private let failureThreshold: Int
    private let resetTimeout: TimeInterval
    private var failureCount: Int = 0
    private var lastFailureTime: Date?
    private var successCount: Int = 0
    
    // MARK: - Initialization
    
    public init(failureThreshold: Int, resetTimeout: TimeInterval) {
        self.failureThreshold = failureThreshold
        self.resetTimeout = resetTimeout
    }
    
    // MARK: - Public Methods
    
    /// Check if request can be made
    public func canMakeRequest() -> Bool {
        switch state {
        case .closed:
            return true
            
        case .open:
            // Check if enough time has passed to try again
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) > resetTimeout {
                state = .halfOpen
                return true
            }
            return false
            
        case .halfOpen:
            return true
        }
    }
    
    /// Record successful request
    public func recordSuccess() {
        switch state {
        case .closed:
            // Normal operation, nothing to do
            break
            
        case .halfOpen:
            successCount += 1
            if successCount >= 3 {  // Require 3 successes to close circuit
                state = .closed
                failureCount = 0
                successCount = 0
            }
            
        case .open:
            // Shouldn't happen, but reset if it does
            state = .closed
            failureCount = 0
        }
    }
    
    /// Record failed request
    public func recordFailure() {
        lastFailureTime = Date()
        
        switch state {
        case .closed:
            failureCount += 1
            if failureCount >= failureThreshold {
                state = .open
            }
            
        case .halfOpen:
            // Failure in half-open state reopens circuit
            state = .open
            failureCount = failureThreshold
            successCount = 0
            
        case .open:
            // Already open, just update failure count
            failureCount += 1
        }
    }
    
    /// Get current state
    public func getState() -> State {
        return state
    }
    
    /// Reset circuit breaker
    public func reset() {
        state = .closed
        failureCount = 0
        successCount = 0
        lastFailureTime = nil
    }
}

// MARK: - Request Queue

/// Queue for offline request handling
public actor RequestQueue {
    
    // MARK: - Properties
    
    private var queue: [QueuedRequest] = []
    private let maxSize: Int
    private let enablePersistence: Bool
    
    // MARK: - Types
    
    private struct QueuedRequest {
        let id: UUID
        let timestamp: Date
        let operation: () async throws -> Any
        let retryCount: Int
    }
    
    // MARK: - Initialization
    
    public init(maxSize: Int, enablePersistence: Bool) {
        self.maxSize = maxSize
        self.enablePersistence = enablePersistence
        
        if enablePersistence {
            loadPersistedQueue()
        }
    }
    
    // MARK: - Public Methods
    
    /// Enqueue request for later processing
    public func enqueue<T>(_ operation: @escaping () async throws -> T) {
        let request = QueuedRequest(
            id: UUID(),
            timestamp: Date(),
            operation: operation,
            retryCount: 0
        )
        
        if queue.count >= maxSize {
            // Remove oldest request
            queue.removeFirst()
        }
        
        queue.append(request)
        
        if enablePersistence {
            persistQueue()
        }
    }
    
    /// Process queued requests
    public func processQueue() async {
        var processedRequests: [UUID] = []
        
        for request in queue {
            do {
                _ = try await request.operation()
                processedRequests.append(request.id)
            } catch {
                // Log error and keep in queue for retry
                print("Failed to process queued request: \(error)")
            }
        }
        
        // Remove successfully processed requests
        queue.removeAll { processedRequests.contains($0.id) }
        
        if enablePersistence {
            persistQueue()
        }
    }
    
    /// Get queue size
    public func getQueueSize() -> Int {
        return queue.count
    }
    
    /// Clear queue
    public func clearQueue() {
        queue.removeAll()
        if enablePersistence {
            clearPersistedQueue()
        }
    }
    
    // MARK: - Private Methods
    
    private func persistQueue() {
        // In a real implementation, serialize and save to disk
        // This is a placeholder
    }
    
    private func loadPersistedQueue() {
        // In a real implementation, load from disk
        // This is a placeholder
    }
    
    private func clearPersistedQueue() {
        // In a real implementation, clear from disk
        // This is a placeholder
    }
}