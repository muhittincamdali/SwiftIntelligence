import Foundation

/// A thread-safe wrapper for mutable state
public final class Locked<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func withLock<U>(_ body: (inout T) throws -> U) rethrows -> U {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
}
